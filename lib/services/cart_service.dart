import 'package:mobile_test/models/product.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _cartItems.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

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
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
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
    }
  }

  void toggleSelection(int productId) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].isSelected = !_cartItems[existingIndex].isSelected;
    }
  }

  void toggleAllSelection(bool selectAll) {
    for (var item in _cartItems) {
      item.isSelected = selectAll;
    }
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
  }

  void clearSelectedItems() {
    _cartItems.removeWhere((item) => item.isSelected);
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

