import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_test/services/auth_service.dart';
import 'package:mobile_test/services/cart_service.dart';
import 'package:mobile_test/services/purchase_service.dart';
import 'package:mobile_test/models/user.dart';
import 'package:mobile_test/screens/login_screen.dart';
import 'package:mobile_test/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  int _cartCount = 0;
  int _purchasedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadCounts();
  }

  Future<void> _loadProfile() async {
    try {
      final authService = AuthService();
      final user = await authService.getProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCounts() async {
    final cartService = CartService();
    setState(() {
      _cartCount = cartService.totalItems;
    });
    final purchasedCount = await PurchaseService.getPurchasedCount();
    setState(() {
      _purchasedCount = purchasedCount;
    });
  }

  Future<void> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nhập mật khẩu của bạn'),
              content: TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(passwordController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await _verifyPasswordAndEdit(result);
    }
  }

  Future<void> _verifyPasswordAndEdit(String password) async {
    if (_user == null) return;

    try {
      // Kiểm tra mật khẩu bằng cách thử đăng nhập
      if (AuthService.accessToken != null && 
          AuthService.accessToken!.startsWith('local_token_')) {
        // Verify password for local users
        final prefs = await SharedPreferences.getInstance();
        final usersKey = 'registered_users';
        final usersJson = prefs.getString(usersKey);
        
        if (usersJson != null) {
          final users = List<Map<String, dynamic>>.from(json.decode(usersJson));
          final tokenParts = AuthService.accessToken!.split('_');
          if (tokenParts.length >= 3) {
            final userId = int.tryParse(tokenParts[2]);
            if (userId != null) {
              final userData = users.firstWhere(
                (u) => u['id'] == userId,
                orElse: () => {},
              );
              
              if (userData.isNotEmpty && userData['password'] == password) {
                // Password đúng, chuyển đến màn hình edit
                if (mounted) {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        user: _user!,
                        currentPassword: password,
                      ),
                    ),
                  );

                  if (updated == true && mounted) {
                    // Reload profile và hiển thị thông báo
                    await _loadProfile();
                    await _loadCounts();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật thông tin thành công!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
                return;
              }
            }
          }
        }
      }
      
      // Password sai
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu không đúng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.clearTokens();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Không thể tải thông tin'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.orange,
                        child: _user!.image.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  _user!.image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                      ),
                      const SizedBox(height: 16),
                      // Tên người dùng
                      Text(
                        _user!.fullName.isNotEmpty ? _user!.fullName : _user!.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _user!.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Hàng thông tin Giỏ hàng và Đã mua
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard('Giỏ hàng', _cartCount.toString()),
                          _buildStatCard('Đã mua', _purchasedCount.toString()),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Thông tin chi tiết
                      _buildInfoCard('Tên đăng nhập', _user!.username),
                      const SizedBox(height: 12),
                      _buildInfoCard('Mật khẩu', '••••••••'),
                      const SizedBox(height: 12),
                      _buildInfoCard('Email', _user!.email),
                      const SizedBox(height: 12),
                      _buildInfoCard('Họ và tên', _user!.fullName.isNotEmpty ? _user!.fullName : 'Chưa cập nhật'),
                      const SizedBox(height: 32),
                      // Nút Chỉnh sửa và Đăng xuất
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _showPasswordDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Chỉnh sửa',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Đăng xuất',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
