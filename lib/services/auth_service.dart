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
      // Thử đăng nhập với tài khoản local trước
      try {
        return await loginLocal(username, password);
      } catch (e) {
        // Nếu không tìm thấy local, thử với API (cho tài khoản demo)
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

    // Kiểm tra nếu là local token
    if (_accessToken!.startsWith('local_token_')) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final usersKey = 'registered_users';
        final usersJson = prefs.getString(usersKey);
        
        if (usersJson != null) {
          final users = List<Map<String, dynamic>>.from(json.decode(usersJson));
          // Lấy user ID từ token
          final tokenParts = _accessToken!.split('_');
          if (tokenParts.length >= 3) {
            final userId = int.tryParse(tokenParts[2]);
            if (userId != null) {
              final user = users.firstWhere(
                (u) => u['id'] == userId,
                orElse: () => throw Exception('Không tìm thấy thông tin người dùng'),
              );
              return User.fromJson(user);
            }
          }
        }
        throw Exception('Không tìm thấy thông tin người dùng');
      } catch (e) {
        throw Exception('Lỗi lấy thông tin: $e');
      }
    }

    // Đăng nhập với API
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

  Future<User> register({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    try {
      // Lưu tài khoản vào local storage
      final prefs = await SharedPreferences.getInstance();
      final usersKey = 'registered_users';
      
      // Lấy danh sách users đã đăng ký
      final usersJson = prefs.getString(usersKey);
      List<Map<String, dynamic>> users = [];
      if (usersJson != null) {
        users = List<Map<String, dynamic>>.from(json.decode(usersJson));
      }
      
      // Kiểm tra username hoặc email đã tồn tại chưa
      if (users.any((u) => u['username'] == username)) {
        throw Exception('Tên đăng nhập đã tồn tại');
      }
      if (users.any((u) => u['email'] == email)) {
        throw Exception('Email đã được sử dụng');
      }
      
      // Tạo user mới
      final newUser = {
        'id': users.length + 1,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password, // Trong thực tế nên hash password
        'gender': '',
        'image': '',
      };
      
      users.add(newUser);
      
      // Lưu lại vào SharedPreferences
      await prefs.setString(usersKey, json.encode(users));
      
      // Tạo User object để trả về
      return User.fromJson(newUser);
    } catch (e) {
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  // Đăng nhập với tài khoản local
  Future<User> loginLocal(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersKey = 'registered_users';
      
      final usersJson = prefs.getString(usersKey);
      if (usersJson == null) {
        throw Exception('Tên đăng nhập hoặc mật khẩu không đúng');
      }
      
      final users = List<Map<String, dynamic>>.from(json.decode(usersJson));
      final user = users.firstWhere(
        (u) => u['username'] == username && u['password'] == password,
        orElse: () => throw Exception('Tên đăng nhập hoặc mật khẩu không đúng'),
      );
      
      // Tạo access token đơn giản (trong thực tế nên dùng JWT)
      final accessToken = 'local_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}';
      final refreshToken = 'refresh_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}';
      
      // Lưu tokens
      await _saveTokens(accessToken, refreshToken);
      
      // Tạo User object với tokens
      final userData = Map<String, dynamic>.from(user);
      userData['accessToken'] = accessToken;
      userData['refreshToken'] = refreshToken;
      
      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }
}

