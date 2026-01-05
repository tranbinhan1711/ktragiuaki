import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_test/models/product.dart';
import 'package:mobile_test/services/product_service.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  static const String _cartKey = 'cart_items';
  final List<CartItem> _cartItems = [];
  bool _isInitialized = false;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _cartItems.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

  // Load cart from SharedPreferences
  Future<void> loadCart() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null && cartJson.isNotEmpty) {
        final List<dynamic> cartData = json.decode(cartJson);
        _cartItems.clear();
        
        for (var itemData in cartData) {
          final productId = itemData['productId'] as int;
          final quantity = itemData['quantity'] as int;
          final isSelected = itemData['isSelected'] as bool? ?? true;
          
          // Tìm product từ ProductService
          final product = ProductService.getProductById(productId);
          if (product != null) {
            _cartItems.add(CartItem(
              product: product,
              quantity: quantity,
              isSelected: isSelected,
            ));
          }
        }
      }
      _isInitialized = true;
    } catch (e) {
      // Nếu có lỗi, giữ cart trống
      _cartItems.clear();
      _isInitialized = true;
    }
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> cartData = _cartItems.map((item) {
        return {
          'productId': item.product.id,
          'quantity': item.quantity,
          'isSelected': item.isSelected,
        };
      }).toList();
      
      final cartJson = json.encode(cartData);
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      // Ignore save errors
    }
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Sản phẩm đã có trong giỏ, tăng số lượng
      _cartItems[existingIndex].quantity += quantity;
    } else {
      // Sản phẩm chưa có, thêm mới
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    _saveCart();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    _saveCart();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity = quantity;
      _saveCart();
    }
  }

  void toggleSelection(int productId) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].isSelected = !_cartItems[existingIndex].isSelected;
      _saveCart();
    }
  }

  void toggleAllSelection(bool selectAll) {
    for (var item in _cartItems) {
      item.isSelected = selectAll;
    }
    _saveCart();
  }

  List<CartItem> getSelectedItems() {
    return _cartItems.where((item) => item.isSelected).toList();
  }

  double getSelectedTotalPrice() {
    return _cartItems
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void clearCart() {
    _cartItems.clear();
    _saveCart();
  }

  void clearSelectedItems() {
    _cartItems.removeWhere((item) => item.isSelected);
    _saveCart();
  }
}

class CartItem {
  final Product product;
  int quantity;
  bool isSelected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = true,
  });
}
