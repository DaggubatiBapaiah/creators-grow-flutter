import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/mediakit_notifier.dart';
import '../../domain/models/mediakit_config.dart';
import '../../../../core/config/app_config.dart';
import '../../../auth/domain/notifiers/auth_notifier.dart';
import '../../../auth/domain/models/auth_state.dart';
import '../../../billing/presentation/widgets/locked_feature_gate.dart';

class MediaKitSettingsScreen extends ConsumerStatefulWidget {
  const MediaKitSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MediaKitSettingsScreen> createState() => _MediaKitSettingsScreenState();
}

class _MediaKitSettingsScreenState extends ConsumerState<MediaKitSettingsScreen> {
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _serviceController = TextEditingController();
  final _rateController = TextEditingController();
  List<RateItem> _rates = [];
  bool _showInstagram = true;
  bool _showTiktok = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mediaKitNotifierProvider.notifier).fetchConfig();
    });
  }

  void _syncState(MediaKitConfig? config) {
    if (config != null) {
      _bioController.text = config.customBio ?? '';
      _emailController.text = config.contactEmail ?? '';
      _rates = List.from(config.rates);
      _showInstagram = config.showInstagram;
      _showTiktok = config.showTiktok;
    }
  }

  void _save() {
    ref.read(mediaKitNotifierProvider.notifier).updateConfig(
          customBio: _bioController.text.trim(),
          contactEmail: _emailController.text.trim(),
          showInstagram: _showInstagram,
          showTiktok: _showTiktok,
          rates: _rates,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mediaKitNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    // Sync controllers on config loaded
    ref.listen<MediaKitState>(mediaKitNotifierProvider, (previous, next) {
      if (next.config != null && previous?.config == null) {
        _syncState(next.config);
      }
    });

    // Generate public link
    String displayNameClean = 'creator';
    if (authState is Authenticated) {
      displayNameClean = authState.user.displayName.replaceAll(' ', '-').toLowerCase();
    }
    final publicLink = '${AppConfig.apiBaseUrl}/api/v1/media-kit/public/kit/$displayNameClean';

    return Scaffold(
      appBar: AppBar(title: const Text('Media Kit Settings')),
      body: LockedFeatureGate(
        featureName: 'Customizable Media Kit',
        checkAccess: (bState) => bState.status?.hasMediaKitCustomization ?? false,
        child: state.isLoading && state.config == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Share Link Widget
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shareable Public Link',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                publicLink,
                                style: const TextStyle(color: Color(0xFF6366F1), decoration: TextDecoration.underline, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              key: const Key('copyLinkButton'),
                              icon: const Icon(Icons.copy_rounded, color: Colors.grey, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: publicLink));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Link copied to clipboard')),
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF334155), height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Kit Page Views', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                            Text(
                              '${state.config?.viewsCount ?? 0}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Configuration Fields
                  const Text('Customize Bio & Profile Details', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('bioField'),
                    controller: _bioController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'A personalized pitch bio displayed to brand managers',
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('contactEmailField'),
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contact Email for Collaborations',
                      labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Platform toggles
                  const Text('Platform Visibility', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Show Instagram Analytics', style: TextStyle(color: Colors.white, fontSize: 14)),
                    value: _showInstagram,
                    onChanged: (val) => setState(() => _showInstagram = val),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Show TikTok Analytics', style: TextStyle(color: Colors.white, fontSize: 14)),
                    value: _showTiktok,
                    onChanged: (val) => setState(() => _showTiktok = val),
                    activeColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  // Rate sheet section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Partnership Rate Sheet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      TextButton.icon(
                        key: const Key('addRateButton'),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Service'),
                        onPressed: () {
                          _serviceController.clear();
                          _rateController.clear();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF1E293B),
                              title: const Text('Add Service Rate', style: TextStyle(color: Colors.white)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    key: const Key('serviceNameField'),
                                    controller: _serviceController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Service Name (e.g. TikTok video)',
                                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    key: const Key('serviceRateField'),
                                    controller: _rateController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Rate (\$)',
                                      labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                                ),
                                ElevatedButton(
                                  key: const Key('saveRateButton'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                                  onPressed: () {
                                    final service = _serviceController.text.trim();
                                    final rateVal = double.tryParse(_rateController.text.trim()) ?? 0.0;
                                    if (service.isNotEmpty) {
                                      setState(() {
                                        _rates.add(RateItem(service: service, rate: rateVal));
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (_rates.isEmpty)
                    const Text('No custom rates entered yet.', style: TextStyle(color: Color(0xFF64748B), fontStyle: FontStyle.italic, fontSize: 13))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _rates.length,
                      itemBuilder: (context, idx) {
                        final rate = _rates[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(rate.service, style: const TextStyle(color: Colors.white)),
                              Row(
                                children: [
                                  Text('\$${rate.rate.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _rates.removeAt(idx);
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  
                  const SizedBox(height: 40),
                  ElevatedButton(
                    key: const Key('saveConfigButton'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _save,
                    child: const Text('SAVE SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}