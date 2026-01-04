import 'package:flutter/material.dart';
import 'package:mobile_test/models/product.dart';
import 'package:mobile_test/services/product_service.dart';
import 'package:mobile_test/services/auth_service.dart';
import 'package:mobile_test/services/cart_service.dart';
import 'package:mobile_test/screens/login_screen.dart';
import 'package:mobile_test/screens/product_detail_screen.dart';

class ProductList extends StatelessWidget {
  final String? selectedCategory;
  final String? searchQuery;
  
  ProductList({super.key, this.selectedCategory, this.searchQuery});

  // Lấy sản phẩm từ service (filter theo category và search query)
  List<Product> get _products {
    List<Product> products;
    
    // Filter theo category trước
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      products = ProductService.getAllProducts();
    } else {
      products = ProductService.getProductsByCategory(selectedCategory!);
    }
    
    // Filter theo search query (Like search)
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase().trim();
      products = products.where((product) {
        return product.title.toLowerCase().contains(query);
      }).toList();
    }
    
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65, // Tăng từ 0.75 để tránh overflow
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(context, _products[index]);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return InkWell(
      onTap: () {
        // Navigate to product detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hình ảnh sản phẩm
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: product.image.isNotEmpty
                    ? Image.asset(
                        product.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.motorcycle,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.motorcycle,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_formatPrice(product.price)} đ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Phần sao và rating
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${product.rating.rate} (${product.rating.count})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Icon thêm vào giỏ hàng
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.orange,
                        size: 20,
                      ),
                      onPressed: () async {
                        // Kiểm tra đăng nhập
                        await AuthService.loadTokens();
                        final isLoggedIn = AuthService.accessToken != null;
                        if (!isLoggedIn) {
                          // Chưa đăng nhập, chuyển đến trang login
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          }
                        } else {
                          // Đã đăng nhập, thêm vào giỏ hàng
                          final cartService = CartService();
                          cartService.addToCart(product);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã thêm ${product.title} vào giỏ hàng'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

