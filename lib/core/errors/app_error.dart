import 'package:dio/dio.dart';

sealed class AppError implements Exception {
  final String message;
  final int? statusCode;

  const AppError(this.message, {this.statusCode});

  @override
  String toString() => 'AppError: $message (status: $statusCode)';
}

class NetworkError extends AppError {
  const NetworkError(super.message, {super.statusCode});
}

class ServerError extends AppError {
  const ServerError(super.message, {super.statusCode});
}

class UnauthorizedError extends AppError {
  const UnauthorizedError({String message = 'Unauthorized access'}) : super(message, statusCode: 401);
}

class StorageError extends AppError {
  const StorageError(super.message);
}

class UnknownError extends AppError {
  const UnknownError(super.message);
}

class AppErrorHandler {
  static AppError handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return const NetworkError('Network connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'Server error occurred.';
          if (statusCode == 401) {
            return UnauthorizedError(message: message.toString());
          }
          return ServerError(message.toString(), statusCode: statusCode);
        default:
          return UnknownError(error.message ?? 'An unknown network error occurred.');
      }
    }
    if (error is AppError) {
      return error;
    }
    return UnknownError(error.toString());
  }
}
