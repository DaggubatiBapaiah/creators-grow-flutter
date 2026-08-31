import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import '../errors/app_error.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final secureStorage = ref.watch(secureStorageProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('[ACCOUNTS FORENSIC] REQUEST START');
        print('[ACCOUNTS FORENSIC] URL: ${options.uri}');
        final token = await secureStorage.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          final tokenHash = sha256.convert(utf8.encode(token)).toString();
          print('[ACCOUNTS FORENSIC] JWT hash = $tokenHash');
        } else {
          print('[ACCOUNTS FORENSIC] JWT hash = NULL');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.requestOptions.uri.path.contains('/accounts')) {
          print('[ACCOUNTS FORENSIC] HTTP STATUS = ${response.statusCode}');
          if (response.data != null && response.data['accounts'] != null) {
            final accs = response.data['accounts'] as List;
            final igAccs = accs.where((a) => a['platform'] == 'instagram').length;
            print('[ACCOUNTS FORENSIC] response account count = ${accs.length}');
            print('[ACCOUNTS FORENSIC] instagram account count = $igAccs');
          }
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        print('[AUTH REGISTER] ERROR TYPE: ${error.type}');
        print('[AUTH REGISTER] ERROR MESSAGE: ${error.message}');
        if (error.response != null) {
          print('[AUTH REGISTER] STATUS: ${error.response?.statusCode}');
          print('[AUTH REGISTER] DATA: ${error.response?.data}');
        }
        
        final appError = AppErrorHandler.handle(error);
        return handler.next(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: appError,
            message: appError.message,
          ),
        );
      },
    ),
  );

  return dio;
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } catch (e) {
      throw AppErrorHandler.handle(e);
    }
  }
}
