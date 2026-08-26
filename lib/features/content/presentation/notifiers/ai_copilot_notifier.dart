import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ai_copilot_service.dart';
import '../../domain/models/ai_variation.dart';
import '../../../../core/network/api_client.dart';

final aiCopilotServiceProvider = Provider<AICopilotService>((ref) {
  final dio = ref.watch(dioProvider);
  return AICopilotService(dio);
});

class AICopilotState {
  final bool isLoading;
  final List<AIVariation> variations;
  final String? error;

  AICopilotState({this.isLoading = false, this.variations = const [], this.error});

  AICopilotState copyWith({bool? isLoading, List<AIVariation>? variations, String? error}) {
    return AICopilotState(
      isLoading: isLoading ?? this.isLoading,
      variations: variations ?? this.variations,
      error: error,
    );
  }
}

class AICopilotNotifier extends StateNotifier<AICopilotState> {
  final AICopilotService _service;

  AICopilotNotifier(this._service) : super(AICopilotState());

  Future<void> generate({required String prompt, required String platform, String? tone}) async {
    state = state.copyWith(isLoading: true, error: null, variations: []);
    try {
      final variations = await _service.generateCaption(prompt: prompt, platform: platform, tone: tone);
      state = state.copyWith(isLoading: false, variations: variations);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void reset() {
    state = AICopilotState();
  }
}

final aiCopilotNotifierProvider = StateNotifierProvider<AICopilotNotifier, AICopilotState>((ref) {
  return AICopilotNotifier(ref.watch(aiCopilotServiceProvider));
});