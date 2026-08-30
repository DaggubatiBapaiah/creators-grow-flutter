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
import '../../features/content/presentation/screens/content_composer_screen.dart';
import '../../features/content/presentation/screens/calendar_screen.dart';
import '../../features/monetization/presentation/screens/crm_pipeline_screen.dart';
import '../../features/monetization/presentation/screens/mediakit_settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final onboardingState = ref.read(onboardingNotifierProvider);

      if (authState is AuthInitial || authState is AuthLoading) {
        debugPrint('[ROUTER_DEBUG] location=${state.matchedLocation} auth=loading redirect=null');
        return null;
      }

      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isWelcoming = state.matchedLocation == '/welcome';

      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');

      final isAuthenticated = authState is Authenticated;
      final isOnboarded = onboardingState.completed;

      debugPrint('[ROUTER_DEBUG] location=${state.matchedLocation} isAuth=$isAuthenticated isOnboarded=$isOnboarded');

      if (!isAuthenticated) {
        if (!isLoggingIn && !isRegistering && !isWelcoming) {
          debugPrint('[ROUTER_DEBUG] redirect to /welcome');
          return '/welcome';
        }
        return null;
      }

      // Authenticated users
      if (!isOnboarded) {
        // If onboarding is incomplete, restrict navigation to onboarding routes
        if (!isOnboardingRoute) {
          debugPrint('[ROUTER_DEBUG] redirect to /onboarding/profile');
          return '/onboarding/profile';
        }
        return null;
      }

      // If onboarding is complete, redirect to /home if trying to access auth/onboarding screens
      if (isLoggingIn || isRegistering || isWelcoming || isOnboardingRoute) {
        debugPrint('[ROUTER_DEBUG] redirect to /home');
        return '/home';
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
      GoRoute(
        path: '/composer',
        builder: (context, state) => const ContentComposerScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/crm',
        builder: (context, state) => const CrmPipelineScreen(),
      ),
      GoRoute(
        path: '/mediakit-settings',
        builder: (context, state) => const MediaKitSettingsScreen(),
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
      (previous, next) {
        if (previous?.completed != next.completed) {
          notifyListeners();
        }
      },
    );
  }
}