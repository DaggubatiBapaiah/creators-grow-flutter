import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/models/auth_state.dart';
import '../../features/auth/domain/notifiers/auth_notifier.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/domain/notifiers/onboarding_notifier.dart';
import '../../features/onboarding/presentation/screens/onboarding_welcome_screen.dart';
import '../../features/onboarding/presentation/screens/creator_profile_screen.dart';
import '../../features/onboarding/presentation/screens/creator_goal_screen.dart';
import '../../features/onboarding/presentation/screens/platform_selection_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/social_accounts/presentation/screens/connected_accounts_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final onboardingState = ref.watch(onboardingNotifierProvider);

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isWelcoming = state.matchedLocation == '/welcome';

      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');

      final isAuthenticated = authState is Authenticated;
      final isOnboarded = onboardingState.completed;

      if (!isAuthenticated) {
        if (!isLoggingIn && !isRegistering && !isWelcoming) {
          return '/welcome';
        }
      } else {
        // Authenticated users
        if (!isOnboarded) {
          // If onboarding is incomplete, restrict navigation to onboarding routes
          if (!isOnboardingRoute) {
            return '/onboarding/welcome';
          }
        } else {
          // If onboarding is complete, redirect to /home if trying to access auth/onboarding screens
          if (isLoggingIn || isRegistering || isWelcoming || isOnboardingRoute) {
            return '/home';
          }
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
        path: '/onboarding/welcome',
        builder: (context, state) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) => const CreatorProfileScreen(),
      ),
      GoRoute(
        path: '/onboarding/goals',
        builder: (context, state) => const CreatorGoalScreen(),
      ),
      GoRoute(
        path: '/onboarding/platforms',
        builder: (context, state) => const PlatformSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/complete',
        builder: (context, state) => const OnboardingCompleteScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/social-accounts',
        builder: (context, state) => const ConnectedAccountsScreen(),
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(
      authNotifierProvider,
      (previous, next) => notifyListeners(),
    );
    ref.listen(
      onboardingNotifierProvider,
      (previous, next) => notifyListeners(),
    );
  }
}