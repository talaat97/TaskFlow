import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Future<void> Function()? onUnauthorized;

  AuthInterceptor({this.onUnauthorized});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var statusCode = err.response?.statusCode;
    if (statusCode == 401 || statusCode == 402) {
      await SecureStorageService.clearAll();

      await onUnauthorized?.call();
    }
    return handler.next(err);
  }
}
