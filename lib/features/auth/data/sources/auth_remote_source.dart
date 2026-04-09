import 'package:dio/dio.dart';
import '../models/auth_model.dart';

class AuthRemoteSource {
  final Dio _dio;

  const AuthRemoteSource({required Dio dio}) : _dio = dio;

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      '/login',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
