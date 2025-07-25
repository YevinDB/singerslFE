class LoginResponse {
  final String token;
  final DateTime expires;
  final String message;

  LoginResponse({
    required this.token,
    required this.expires,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      expires: DateTime.parse(json['expires']),
      message: json['message'] ?? '',
    );
  }
}
