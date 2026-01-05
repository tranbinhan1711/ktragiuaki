import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  static const String _purchasedCountKey = 'purchased_items_count';

  // Lấy số sản phẩm đã mua
  static Future<int> getPurchasedCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_purchasedCountKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // Tăng số sản phẩm đã mua (khi thanh toán thành công)
  static Future<void> addPurchasedCount(int quantity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_purchasedCountKey) ?? 0;
      await prefs.setInt(_purchasedCountKey, currentCount + quantity);
    } catch (e) {
      // Ignore errors
    }
  }

  // Reset số sản phẩm đã mua (nếu cần)
  static Future<void> resetPurchasedCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_purchasedCountKey);
    } catch (e) {
      // Ignore errors
    }
  }
}

