import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:singer_sl/models/api_response.dart';
import 'package:singer_sl/models/login_response.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:5017';

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  DateTime? _tokenExpiry;

  void _storeToken(String token, DateTime expiry) {
    _token = token;
    _tokenExpiry = expiry;
  }

  String? getToken() {
    if (_token != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _token;
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    return getToken() != null;
  }

  Future<ApiResponse<LoginResponse>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<LoginResponse>.fromJson(
          jsonResponse,
          (data) => LoginResponse.fromJson(data),
        );

        if (apiResponse.success && apiResponse.data != null) {
          _storeToken(apiResponse.data!.token, apiResponse.data!.expires);
        }

        return apiResponse;
      } else {
        return ApiResponse<LoginResponse>.fromJson(jsonResponse, null);
      }
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        message: 'Network error occurred',
        errors: [e.toString()],
      );
    }
  }

  void logout() {
    _token = null;
    _tokenExpiry = null;
  }
}
