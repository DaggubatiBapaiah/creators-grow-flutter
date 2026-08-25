import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/models/auth_state.dart';
import '../../features/auth/domain/notifiers/auth_notifier.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/welcome',
    // Force router logic evaluation on authentication status updates
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isWelcoming = state.matchedLocation == '/welcome';

      final isAuthenticated = authState is Authenticated;

      if (!isAuthenticated) {
        if (!isLoggingIn && !isRegistering && !isWelcoming) {
          return '/welcome';
        }
      } else {
        // Redirect to /home if trying to access auth screens when logged in
        if (isLoggingIn || isRegistering || isWelcoming) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});

// Helper class to trigger GoRouter refreshes on Riverpod notifications
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(
      authNotifierProvider,
      (_, unused) => notifyListeners(),
    );
  }
}
