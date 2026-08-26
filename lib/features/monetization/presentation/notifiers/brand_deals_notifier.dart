import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/brand_deal.dart';
import '../../data/repositories/monetization_repository.dart';

class BrandDealsState {
  final bool isLoading;
  final List<BrandDeal> deals;
  final String? error;

  BrandDealsState({this.isLoading = false, this.deals = const [], this.error});

  BrandDealsState copyWith({bool? isLoading, List<BrandDeal>? deals, String? error}) {
    return BrandDealsState(
      isLoading: isLoading ?? this.isLoading,
      deals: deals ?? this.deals,
      error: error,
    );
  }
}

class BrandDealsNotifier extends StateNotifier<BrandDealsState> {
  final MonetizationRepository _repository;

  BrandDealsNotifier(this._repository) : super(BrandDealsState()) {
    fetchDeals();
  }

  Future<void> fetchDeals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final deals = await _repository.getDeals();
      state = state.copyWith(isLoading: false, deals: deals);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createDeal({
    required String brandName,
    required double dealValue,
    required String stage,
    String? contactPerson,
    String? contactEmail,
    String? notes,
    String? associatedPostId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newDeal = await _repository.createDeal(
        brandName: brandName,
        dealValue: dealValue,
        stage: stage,
        contactPerson: contactPerson,
        contactEmail: contactEmail,
        notes: notes,
        associatedPostId: associatedPostId,
      );
      state = state.copyWith(isLoading: false, deals: [newDeal, ...state.deals]);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateDealStage(String id, String stage) async {
    try {
      final updatedDeal = await _repository.updateDeal(id, {'stage': stage});
      state = state.copyWith(
        deals: state.deals.map((d) => d.id == id ? updatedDeal : d).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateDeal(String id, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedDeal = await _repository.updateDeal(id, updates);
      state = state.copyWith(
        isLoading: false,
        deals: state.deals.map((d) => d.id == id ? updatedDeal : d).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteDeal(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteDeal(id);
      state = state.copyWith(
        isLoading: false,
        deals: state.deals.where((d) => d.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final brandDealsNotifierProvider = StateNotifierProvider<BrandDealsNotifier, BrandDealsState>((ref) {
  return BrandDealsNotifier(ref.watch(monetizationRepositoryProvider));
});