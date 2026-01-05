import 'package:flutter/material.dart';
import 'package:mobile_test/screens/home_screen.dart';
import 'package:mobile_test/screens/cart_screen.dart';
import 'package:mobile_test/screens/profile_screen.dart';
import 'package:mobile_test/screens/login_screen.dart';
import 'package:mobile_test/services/auth_service.dart';
import 'package:mobile_test/services/cart_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load tokens và cart khi app khởi động
  await AuthService.loadTokens();
  await CartService().loadCart();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ứng dụng bán xe máy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem đã đăng nhập chưa
    final isLoggedIn = AuthService.accessToken != null;
    
    if (isLoggedIn) {
      return const MainNavigationScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onCartTap: () => _changeTab(1),
        onProfileTap: () => _changeTab(2),
      ),
      const CartScreen(),
      const ProfileScreen(),
    ];
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tôi',
          ),
        ],
      ),
    );
  }
}
