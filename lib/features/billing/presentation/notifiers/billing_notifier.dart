import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/billing_status.dart';
import '../../data/repositories/billing_repository.dart';
import '../../../auth/domain/notifiers/auth_notifier.dart';
import '../../../auth/domain/models/auth_state.dart';

class BillingState {
  final BillingStatus? status;
  final bool isLoading;
  final String? error;
  final bool isUpgrading;

  BillingState({
    this.status,
    this.isLoading = false,
    this.error,
    this.isUpgrading = false,
  });

  BillingState copyWith({
    BillingStatus? status,
    bool? isLoading,
    String? error,
    bool? isUpgrading,
  }) {
    return BillingState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUpgrading: isUpgrading ?? this.isUpgrading,
    );
  }
}

class BillingNotifier extends StateNotifier<BillingState> {
  final BillingRepository _repository;
  final Ref _ref;

  BillingNotifier(this._repository, this._ref) : super(BillingState()) {
    // Refresh subscription status automatically when user logs in
    _ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is Authenticated) {
        loadStatus();
      }
    });
    loadStatus();
  }

  Future<void> loadStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final status = await _repository.getStatus();
      state = state.copyWith(status: status, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> upgrade(String planCode) async {
    state = state.copyWith(isUpgrading: true, error: null);
    try {
      final checkoutData = await _repository.createCheckout(planCode);
      final subId = checkoutData['subscriptionId'] as String;
      
      // Simulate/trigger successful payment flow
      final authState = _ref.read(authNotifierProvider);
      if (authState is Authenticated) {
        final user = authState.user;
        await _repository.simulatePaymentSuccess(subId, planCode, user.id);
        // Refresh status immediately
        await loadStatus();
      }
      state = state.copyWith(isUpgrading: false);
    } catch (e) {
      state = state.copyWith(isUpgrading: false, error: e.toString());
    }
  }
}

final billingNotifierProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  return BillingNotifier(ref.watch(billingRepositoryProvider), ref);
});
