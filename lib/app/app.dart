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

    final isCustomScheme = uri.scheme == 'creatorsgrow' && uri.host == 'oauth' && uri.path == '/callback';
    final isHttpsApplink = (uri.scheme == 'https' || uri.scheme == 'http') && uri.host == 'creatorsgrowbackend-flutter.vercel.app' && uri.path == '/oauth/callback';

    if (isCustomScheme || isHttpsApplink) {
      print('[DEEPLINK FORENSIC] Triggering fetchAccounts() due to valid OAuth callback');
      ref.read(socialAccountsNotifierProvider.notifier).fetchAccounts();
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
