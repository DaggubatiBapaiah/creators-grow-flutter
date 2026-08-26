import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/brand_deal.dart';
import '../../domain/models/mediakit_config.dart';

final monetizationRepositoryProvider = Provider<MonetizationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MonetizationRepository(dio);
});

class MonetizationRepository {
  final Dio _dio;

  MonetizationRepository(this._dio);

  // BRAND DEALS
  Future<List<BrandDeal>> getDeals() async {
    final response = await _dio.get('/api/v1/crm/deals');
    final List list = response.data['data']['deals'] ?? [];
    return list.map((e) => BrandDeal.fromJson(e)).toList();
  }

  Future<BrandDeal> createDeal({
    required String brandName,
    required double dealValue,
    required String stage,
    String? contactPerson,
    String? contactEmail,
    String? notes,
    String? associatedPostId,
  }) async {
    final response = await _dio.post('/api/v1/crm/deals', data: {
      'brandName': brandName,
      'dealValue': dealValue,
      'stage': stage,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'notes': notes,
      'associatedPostId': associatedPostId,
    });
    return BrandDeal.fromJson(response.data['data']['deal']);
  }

  Future<BrandDeal> updateDeal(String id, Map<String, dynamic> updates) async {
    final response = await _dio.put('/api/v1/crm/deals/$id', data: updates);
    return BrandDeal.fromJson(response.data['data']['deal']);
  }

  Future<void> deleteDeal(String id) async {
    await _dio.delete('/api/v1/crm/deals/$id');
  }

  // MEDIA KIT
  Future<MediaKitConfig> getConfig() async {
    final response = await _dio.get('/api/v1/media-kit/config');
    return MediaKitConfig.fromJson(response.data['data']['config']);
  }

  Future<MediaKitConfig> saveConfig(MediaKitConfig config) async {
    final response = await _dio.post('/api/v1/media-kit/config', data: {
      'customBio': config.customBio,
      'contactEmail': config.contactEmail,
      'showInstagram': config.showInstagram,
      'showTiktok': config.showTiktok,
      'rates': config.rates.map((e) => e.toJson()).toList(),
    });
    return MediaKitConfig.fromJson(response.data['data']['config']);
  }
}