class AuthRequest {
  final String email;
  final String password;

  const AuthRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class AuthResponse {
  final String accessToken;
  final int userId;
  final String email;
  final String name;

  const AuthResponse({
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.name,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return AuthResponse(
      accessToken: json['accessToken'] as String? ?? '',
      userId: (user['id'] as num?)?.toInt() ?? 0,
      email: user['email'] as String? ?? '',
      name: user['name'] as String? ?? '',
    );
  }
}
