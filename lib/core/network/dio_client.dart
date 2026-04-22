import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio? _instance;

  static void init({Future<void> Function()? onUnauthorized}) {
    _instance = _build(onUnauthorized: onUnauthorized);
  }

  static Dio get instance {
    _instance ??= _build();
    return _instance!;
  }

  static Dio _build({Future<void> Function()? onUnauthorized}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(onUnauthorized: onUnauthorized),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    ]);

    return dio;
  }

  static void reset() => _instance = null;
}

// ignore: avoid_print
void debugPrint(String msg) => print('[DioClient] $msg');
