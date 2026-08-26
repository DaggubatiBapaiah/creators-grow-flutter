import 'package:dio/dio.dart';
import '../domain/models/ai_variation.dart';

class AICopilotService {
  final Dio _dio;

  AICopilotService(this._dio);

  Future<List<AIVariation>> generateCaption({
    required String prompt,
    required String platform,
    String? tone,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/ai/generate-caption',
        data: {
          'prompt': prompt,
          'platform': platform.toUpperCase(),
          if (tone != null) 'tone': tone,
        },
      );

      final List data = response.data['data']['variations'] ?? [];
      return data.map((v) => AIVariation.fromJson(v)).toList();
    } on DioException catch (e) {
      final message = e.response?.data['error']?['message'] ?? 'Failed to generate captions';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to generate captions: ');
    }
  }
}