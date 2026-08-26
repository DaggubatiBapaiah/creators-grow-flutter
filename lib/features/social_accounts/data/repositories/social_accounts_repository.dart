import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_error.dart';
import '../../domain/models/social_account.dart';
import '../../domain/models/social_platform.dart';

final socialAccountsRepositoryProvider = Provider<SocialAccountsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return SocialAccountsRepository(dio);
});

class SocialAccountsRepository {
  final Dio _dio;

  SocialAccountsRepository(this._dio);

  Future<List<SocialAccount>> getConnectedAccounts() async {
    try {
      final response = await _dio.get('/api/v1/social/accounts');
      final data = response.data as Map<String, dynamic>;
      final list = data['accounts'] as List<dynamic>;
      return list.map((item) => SocialAccount.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }

  Future<void> disconnectAccount(String id) async {
    try {
      await _dio.delete('/api/v1/social/accounts/$id');
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }

  Future<String> getConnectUrl(SocialPlatform platform) async {
    try {
      final response = await _dio.post('/api/v1/social/${platform.name}/connect');
      final data = response.data as Map<String, dynamic>;
      return data['authUrl'] as String;
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }
}
