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
          return const NetworkError('Connection timeout (took too long to connect).');
        case DioExceptionType.sendTimeout:
          return const NetworkError('Send timeout (took too long to send request).');
        case DioExceptionType.receiveTimeout:
          return const NetworkError('Receive timeout (server took too long to respond).');
        case DioExceptionType.connectionError:
          return NetworkError('Connection error (refused or unreachable). Details: ${error.message}');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? error.response?.data?['error'] ?? 'Server error occurred.';
          if (statusCode == 401) {
            return UnauthorizedError(message: message.toString());
          }
          if (statusCode == 400 || statusCode == 409 || statusCode == 422) {
            return ServerError(message.toString(), statusCode: statusCode);
          }
          return ServerError('Server responded with $statusCode: $message', statusCode: statusCode);
        default:
          return UnknownError(error.message ?? 'An unknown network error occurred (${error.type.name}).');
      }
    }
    if (error is AppError) {
      return error;
    }
    return UnknownError(error.toString());
  }
}
