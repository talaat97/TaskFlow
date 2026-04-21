import '../models/user_entity.dart';
import '../models/auth_model.dart';
import '../sources/auth_remote_source.dart';
import '../../../../core/storage/secure_storage.dart';

class AuthRepository {
  final AuthRemoteSource _remote;

  const AuthRepository({required AuthRemoteSource remote}) : _remote = remote;

  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final response =
        await _remote.login(AuthRequest(email: email, password: password));

    await SecureStorageService.saveToken(response.accessToken);
    await SecureStorageService.saveUserInfo(
      email: response.email,
      name: response.name,
    );

    return UserEntity(
      id: response.userId,
      email: response.email,
      name: response.name,
    );
  }

  Future<void> logout() => SecureStorageService.clearAll();
}
