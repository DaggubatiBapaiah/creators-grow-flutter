import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'router/router.dart';
import '../core/theme/app_theme.dart';
import '../features/social_accounts/presentation/notifiers/social_accounts_notifier.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Check initial link if app was in cold state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri, isInitial: true);
      }
    } catch (e) {
      print('[DEEPLINK FORENSIC] Error getting initial link: $e');
    }

    // Handle link when app is in warm state
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri, isInitial: false);
    });
  }

  void _handleDeepLink(Uri uri, {required bool isInitial}) {
    print('[DEEPLINK FORENSIC] URI RECEIVED');
    print('[DEEPLINK FORENSIC] type = ${isInitial ? "initial" : "runtime"}');
    print('[DEEPLINK FORENSIC] scheme = ${uri.scheme}');
    print('[DEEPLINK FORENSIC] host = ${uri.host}');
    print('[DEEPLINK FORENSIC] path = ${uri.path}');
    print('[DEEPLINK FORENSIC] status query = ${uri.queryParameters["status"]}');

    final isHttpsApplink = (uri.scheme == 'https' || uri.scheme == 'http') && uri.host == 'app.creatorsgrow.co.in' && uri.path == '/oauth/callback';

    if (isHttpsApplink) {
      final status = uri.queryParameters['status'];
      
      if (status == 'success') {
        print('[OAUTH HANDOFF] SUCCESS LINK RECEIVED');
        ref.read(socialAccountsNotifierProvider.notifier).fetchAccounts();
        // Since the accounts screen might not be in focus, or we might need to navigate there,
        // typically the router can go to '/accounts' but we might already be there. 
        // We'll let the user see it updated if they are on the screen. 
        // If not, we could push it, but we'll show a snackbar for now to notify them.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully connected account!'), backgroundColor: Colors.green),
            );
          }
        });
      } else if (status == 'error') {
        final message = uri.queryParameters['message'] ?? 'Unknown error occurred.';
        print('[OAUTH HANDOFF] ERROR LINK RECEIVED: $message');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to connect: $message'), backgroundColor: Colors.red),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CreatorsGrow',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
