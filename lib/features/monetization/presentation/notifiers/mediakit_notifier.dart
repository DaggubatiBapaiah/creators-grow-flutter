import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/mediakit_config.dart';
import '../../data/repositories/monetization_repository.dart';

class MediaKitState {
  final bool isLoading;
  final MediaKitConfig? config;
  final String? error;

  MediaKitState({this.isLoading = false, this.config, this.error});

  MediaKitState copyWith({bool? isLoading, MediaKitConfig? config, String? error}) {
    return MediaKitState(
      isLoading: isLoading ?? this.isLoading,
      config: config ?? this.config,
      error: error,
    );
  }
}

class MediaKitNotifier extends StateNotifier<MediaKitState> {
  final MonetizationRepository _repository;

  MediaKitNotifier(this._repository) : super(MediaKitState()) {
    fetchConfig();
  }

  Future<void> fetchConfig() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final config = await _repository.getConfig();
      state = state.copyWith(isLoading: false, config: config);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateConfig({
    String? customBio,
    String? contactEmail,
    bool? showInstagram,
    bool? showTiktok,
    List<RateItem>? rates,
  }) async {
    if (state.config == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newConfig = state.config!.copyWith(
        customBio: customBio,
        contactEmail: contactEmail,
        showInstagram: showInstagram,
        showTiktok: showTiktok,
        rates: rates,
      );
      final savedConfig = await _repository.saveConfig(newConfig);
      state = state.copyWith(isLoading: false, config: savedConfig);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final mediaKitNotifierProvider = StateNotifierProvider<MediaKitNotifier, MediaKitState>((ref) {
  return MediaKitNotifier(ref.watch(monetizationRepositoryProvider));
});