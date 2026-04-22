import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/sources/auth_remote_source.dart';
import '../../data/models/user_entity.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';

// ─── Infrastructure Providers ─────────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) => DioClient.instance);

final authRemoteSourceProvider = Provider<AuthRemoteSource>(
  (ref) => AuthRemoteSource(dio: ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(remote: ref.watch(authRemoteSourceProvider)),
);

// ─── Auth State ───────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        errorMessage: errorMessage,
      );

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState());

  /// Called from SplashScreen — checks stored token.
  Future<void> checkAuth() async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    final info = await SecureStorageService.getUserInfo();
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: UserEntity(
        id: 0,
        email: info['email'] ?? '',
        name: info['name'] ?? '',
      ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on DioException catch (e) {
      final msg = e.response?.statusCode == 400 || e.response?.statusCode == 401
          ? 'Invalid email or password'
          : 'Connection failed. Is the mock API running?';
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred.',
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    DioClient.reset();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
    (ref) => AuthNotifier(ref.watch(authRepositoryProvider)));
