import 'package:flutter/material.dart';
import 'package:mobile_test/widgets/category_sidebar.dart';
import 'package:mobile_test/widgets/product_list.dart';
import 'package:mobile_test/widgets/search_bar.dart';
import 'package:mobile_test/services/auth_service.dart';
import 'package:mobile_test/models/user.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onCartTap;
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    this.onCartTap,
    this.onProfileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCategoryExpanded = false;
  String? _selectedCategory; // Danh mục được chọn
  String? _searchQuery; // Từ khóa tìm kiếm
  User? _user;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final authService = AuthService();
      final user = await authService.getProfile();
      setState(() {
        _user = user;
      });
    } catch (e) {
      // Ignore error, sẽ hiển thị "User" nếu không load được
    }
  }

  String get _lastName {
    if (_user == null) return 'User';
    if (_user!.lastName.isNotEmpty) {
      return _user!.lastName;
    }
    return _user!.username;
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header với logo, search, icons
            _buildHeader(),
            // Body với danh mục và list sản phẩm
            Expanded(
              child: Row(
                children: [
                  // Danh mục bên trái
                  CategorySidebar(
                    isExpanded: _isCategoryExpanded,
                    onToggle: () {
                      setState(() {
                        _isCategoryExpanded = !_isCategoryExpanded;
                      });
                    },
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                  ),
                  // List sản phẩm bên phải
                  Expanded(
                    child: ProductList(
                      selectedCategory: _selectedCategory,
                      searchQuery: _searchQuery,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo bên trái (cố định)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.motorcycle,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          // Spacer để đẩy search bar ra giữa
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Search bar với width cố định hoặc max width
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: CustomSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        // Tìm kiếm real-time khi gõ
                        setState(() {
                          _searchQuery = value.isEmpty ? null : value;
                        });
                      },
                      onSearch: () {
                        // Tìm kiếm khi nhấn Enter hoặc nút Tìm
                        setState(() {
                          _searchQuery = _searchController.text.isEmpty
                              ? null
                              : _searchController.text;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Nút Tìm
                InkWell(
                  onTap: () {
                    setState(() {
                      _searchQuery = _searchController.text.isEmpty
                          ? null
                          : _searchController.text;
                    });
                  },
                  child: Container(
                    height: 38 * 3 / 5, // 3/5 của height hiện tại
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: const Text(
                      'Tim',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Phần bên phải (cố định)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon giỏ hàng
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: widget.onCartTap,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              // Icon tài khoản
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: widget.onProfileTap,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
                // Hi + last name
                Text(
                  'Hi $_lastName',
                  style: const TextStyle(
                    fontSize: 10,
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

