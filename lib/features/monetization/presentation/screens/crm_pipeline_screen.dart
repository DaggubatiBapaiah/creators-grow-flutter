import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../notifiers/brand_deals_notifier.dart';
import '../../domain/models/brand_deal.dart';
import '../../../content/presentation/notifiers/content_notifier.dart';

class CrmPipelineScreen extends ConsumerStatefulWidget {
  const CrmPipelineScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CrmPipelineScreen> createState() => _CrmPipelineScreenState();
}

class _CrmPipelineScreenState extends ConsumerState<CrmPipelineScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(brandDealsNotifierProvider.notifier).fetchDeals();
      ref.read(contentNotifierProvider.notifier).loadPosts();
    });
  }

  void _showAddDealDialog([BrandDeal? deal]) {
    final isEdit = deal != null;
    final brandController = TextEditingController(text: deal?.brandName);
    final valueController = TextEditingController(text: deal != null ? deal.dealValue.toString() : '');
    final notesController = TextEditingController(text: deal?.notes);
    final contactPersonController = TextEditingController(text: deal?.contactPerson);
    final contactEmailController = TextEditingController(text: deal?.contactEmail);
    String selectedStage = deal?.stage ?? 'pitching';
    String? selectedPostId = deal?.associatedPostId;

    showDialog(
      context: context,
      builder: (context) {
        final postsState = ref.watch(contentNotifierProvider);
        final publishedPosts = postsState.posts.where((p) => p.status == 'published').toList();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              key: const Key('dealDialog'),
              backgroundColor: const Color(0xFF1E293B),
              title: Text(isEdit ? 'Edit Brand Deal' : 'Add Brand Deal', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      key: const Key('brandNameField'),
                      controller: brandController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Brand Name',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('dealValueField'),
                      controller: valueController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Deal Value (\$)',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: const Key('stageDropdown'),
                      value: selectedStage,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Stage',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'pitching', child: Text('Pitching')),
                        DropdownMenuItem(value: 'negotiating', child: Text('Negotiating')),
                        DropdownMenuItem(value: 'signed', child: Text('Signed')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() => selectedStage = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contactPersonController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Contact Person',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: contactEmailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      value: selectedPostId,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Linked Published Post',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None', style: TextStyle(color: Colors.grey))),
                        ...publishedPosts.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            p.caption != null && p.caption!.length > 25 
                                ? '${p.caption!.substring(0, 25)}...' 
                                : (p.caption ?? 'Post #${p.id.substring(0,4)}'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                      ],
                      onChanged: (val) {
                        setStateDialog(() => selectedPostId = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF334155))),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
                ElevatedButton(
                  key: const Key('saveDealButton'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                  onPressed: () {
                    final brand = brandController.text.trim();
                    final val = double.tryParse(valueController.text.trim()) ?? 0.0;
                    if (brand.isEmpty) return;

                    final notifier = ref.read(brandDealsNotifierProvider.notifier);
                    if (isEdit) {
                      notifier.updateDeal(deal.id, {
                        'brandName': brand,
                        'dealValue': val,
                        'stage': selectedStage,
                        'contactPerson': contactPersonController.text.trim(),
                        'contactEmail': contactEmailController.text.trim(),
                        'notes': notesController.text.trim(),
                        'associatedPostId': selectedPostId,
                      });
                    } else {
                      notifier.createDeal(
                        brandName: brand,
                        dealValue: val,
                        stage: selectedStage,
                        contactPerson: contactPersonController.text.trim(),
                        contactEmail: contactEmailController.text.trim(),
                        notes: notesController.text.trim(),
                        associatedPostId: selectedPostId,
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brandDealsNotifierProvider);

    // Calculate aggregated values
    double pipelineValue = 0.0;
    double paidRevenue = 0.0;
    for (final d in state.deals) {
      if (d.stage == 'negotiating' || d.stage == 'signed' || d.stage == 'completed') {
        pipelineValue += d.dealValue;
      } else if (d.stage == 'paid') {
        paidRevenue += d.dealValue;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Deals CRM'),
        actions: [
          IconButton(
            key: const Key('addDealIconBtn'),
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _showAddDealDialog(),
          ),
        ],
      ),
      body: state.isLoading && state.deals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(brandDealsNotifierProvider.notifier).fetchDeals(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Financial summary header
                    Row(
                      children: [
                        Expanded(
                          child: _FinancialSummaryCard(
                            title: 'Active Pipeline',
                            value: '\$${pipelineValue.toStringAsFixed(2)}',
                            color: Colors.indigoAccent,
                            icon: Icons.analytics_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FinancialSummaryCard(
                            title: 'Paid Earnings',
                            value: '\$${paidRevenue.toStringAsFixed(2)}',
                            color: const Color(0xFF10B981),
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    if (state.deals.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.0),
                          child: Text(
                            'No brand deals registered yet. Click the + button to add one.',
                            style: TextStyle(color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.deals.length,
                        itemBuilder: (context, idx) {
                          final deal = state.deals[idx];
                          return Card(
                            color: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              key: Key('dealItem_${deal.id}'),
                              title: Text(deal.brandName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text('\$${deal.dealValue.toStringAsFixed(2)}', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 12),
                                      _StageChip(stage: deal.stage),
                                    ],
                                  ),
                                  if (deal.notes != null && deal.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(deal.notes!, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ]
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                                    onPressed: () => _showAddDealDialog(deal),
                                  ),
                                  IconButton(
                                    key: Key('deleteDealBtn_${deal.id}'),
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      ref.read(brandDealsNotifierProvider.notifier).deleteDeal(deal.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _FinancialSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _FinancialSummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _StageChip extends StatelessWidget {
  final String stage;

  const _StageChip({required this.stage});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (stage) {
      case 'pitching':
        bg = Colors.amber.withOpacity(0.15);
        fg = Colors.amber[400]!;
        break;
      case 'negotiating':
        bg = Colors.blue.withOpacity(0.15);
        fg = Colors.blue[400]!;
        break;
      case 'signed':
        bg = Colors.indigo.withOpacity(0.15);
        fg = Colors.indigo[400]!;
        break;
      case 'completed':
        bg = Colors.teal.withOpacity(0.15);
        fg = Colors.teal[400]!;
        break;
      case 'paid':
        bg = Colors.green.withOpacity(0.15);
        fg = Colors.green[400]!;
        break;
      default:
        bg = Colors.grey.withOpacity(0.15);
        fg = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        stage.toUpperCase(),
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.05),
      ),
    );
  }
}