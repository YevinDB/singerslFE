import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:singer_sl/models/api_response.dart';
import 'package:singer_sl/models/product.dart';
import 'package:singer_sl/services/auth_service.dart';

class ProductService {
  static const String baseUrl = 'http://localhost:5017';
  final AuthService _authService = AuthService();

  Map<String, String> _getHeaders() {
    final token = _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse<Product>> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/product'),
        headers: _getHeaders(),
        body: jsonEncode(product.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<Product>.fromJson(
          jsonResponse,
          (data) => Product.fromJson(data),
        );
      } else {
        return ApiResponse<Product>.fromJson(jsonResponse, null);
      }
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Network error occurred',
        errors: [e.toString()],
      );
    }
  }

  Future<ApiResponse<Product>> updateProduct(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/product/$id'),
        headers: _getHeaders(),
        body: jsonEncode(product.toJson()),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Product>.fromJson(
          jsonResponse,
          (data) => Product.fromJson(data),
        );
      } else {
        return ApiResponse<Product>.fromJson(jsonResponse, null);
      }
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Network error occurred',
        errors: [e.toString()],
      );
    }
  }

  Future<ApiResponse<List<Product>>> searchProducts(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/api/product/search').replace(
        queryParameters: query.isNotEmpty ? {'query': query} : null,
      );

      final response = await http.get(uri, headers: _getHeaders());
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<List<Product>>.fromJson(
          jsonResponse,
          (data) =>
              (data as List).map((item) => Product.fromJson(item)).toList(),
        );
      } else {
        return ApiResponse<List<Product>>.fromJson(jsonResponse, null);
      }
    } catch (e) {
      return ApiResponse<List<Product>>(
        success: false,
        message: 'Network error occurred',
        errors: [e.toString()],
      );
    }
  }

  Future<ApiResponse<Product>> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/product/$id'),
        headers: _getHeaders(),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Product>.fromJson(
          jsonResponse,
          (data) => Product.fromJson(data),
        );
      } else {
        return ApiResponse<Product>.fromJson(
          jsonResponse,
          null,
        );
      }
    } catch (e) {
      return ApiResponse<Product>(
        success: false,
        message: 'Network error occurred',
        errors: [e.toString()],
      );
    }
  }
}
