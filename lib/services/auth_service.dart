import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_test/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://dummyjson.com';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static String? _accessToken;
  static String? _refreshToken;

  // Load tokens from SharedPreferences
  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }

  // Save tokens to SharedPreferences
  static Future<void> _saveTokens(String? accessToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    if (accessToken != null && accessToken.isNotEmpty) {
      await prefs.setString(_accessTokenKey, accessToken);
      _accessToken = accessToken;
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await prefs.setString(_refreshTokenKey, refreshToken);
      _refreshToken = refreshToken;
    }
  }

  // Clear tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    _accessToken = null;
    _refreshToken = null;
  }

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;

  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
          'expiresInMins': 30,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        
        // Lưu tokens vào SharedPreferences
        await _saveTokens(user.accessToken, user.refreshToken);
        
        return user;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  Future<User> getProfile() async {
    // Load tokens nếu chưa có
    if (_accessToken == null) {
      await loadTokens();
    }

    if (_accessToken == null) {
      throw Exception('Chưa đăng nhập');
    }

    try {
      var response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      // Nếu accessToken hết hạn, thử refresh
      if (response.statusCode == 401 && _refreshToken != null) {
        try {
          final tokens = await _refreshAccessToken(_refreshToken!);
          // Thử lại với accessToken mới
          response = await http.get(
            Uri.parse('$baseUrl/auth/me'),
            headers: {
              'Authorization': 'Bearer ${tokens['accessToken']}',
            },
          );
        } catch (e) {
          // Refresh thất bại, cần đăng nhập lại
          await clearTokens();
          throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        }
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Không thể lấy thông tin profile');
      }
    } catch (e) {
      throw Exception('Lỗi lấy thông tin: $e');
    }
  }

  Future<Map<String, String>> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'refreshToken': refreshToken,
          'expiresInMins': 30,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Lưu tokens mới
        await _saveTokens(data['accessToken'], data['refreshToken']);
        return {
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken'],
        };
      } else {
        throw Exception('Không thể refresh token');
      }
    } catch (e) {
      throw Exception('Lỗi refresh token: $e');
    }
  }
}

