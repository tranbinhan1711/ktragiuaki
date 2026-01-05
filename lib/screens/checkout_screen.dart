import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_test/services/cart_service.dart';
import 'package:mobile_test/services/purchase_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> selectedItems;

  const CheckoutScreen({
    super.key,
    required this.selectedItems,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Chỉ cho phép số và dấu /
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Giới hạn 8 chữ số (DDMMYYYY)
    if (digitsOnly.length > 8) {
      return oldValue;
    }
    
    // Format: DD/MM/YYYY
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }
    
    // Tính cursor position
    int cursorPosition = formatted.length;
    if (newValue.selection.baseOffset < text.length) {
      // Giữ cursor position tương đối
      final digitsBeforeCursor = text.substring(0, newValue.selection.baseOffset).replaceAll(RegExp(r'[^\d]'), '').length;
      cursorPosition = digitsBeforeCursor + (digitsBeforeCursor > 2 ? 1 : 0) + (digitsBeforeCursor > 4 ? 1 : 0);
      if (cursorPosition > formatted.length) {
        cursorPosition = formatted.length;
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _accountNumberController = TextEditingController();
  DateTime? _selectedDate;
  final _dateController = TextEditingController();
  String? _selectedBank;

  static const List<String> _banks = [
    'Vietcombank (VCB)',
    'BIDV',
    'VietinBank',
    'Agribank',
    'Techcombank',
    'ACB (Ngân hàng Á Châu)',
    'VPBank',
    'MBBank (Ngân hàng Quân đội)',
    'TPBank',
    'Sacombank',
    'HDBank',
    'Vietbank',
    'SHB (Ngân hàng Sài Gòn - Hà Nội)',
    'Eximbank',
    'SCB (Ngân hàng Sài Gòn)',
    'MSB (Ngân hàng Hàng Hải)',
    'OCB (Ngân hàng Phương Đông)',
    'VIB (Ngân hàng Quốc tế)',
    'SeABank',
    'PVcomBank',
  ];

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _accountNumberController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  DateTime? _parseDateFromString(String value) {
    if (value.isEmpty) return null;
    
    // Format: DD/MM/YYYY
    final RegExp dateRegex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    final match = dateRegex.firstMatch(value);
    
    if (match == null) return null;
    
    try {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);
      
      // Kiểm tra giá trị hợp lệ
      if (month < 1 || month > 12) return null;
      if (day < 1 || day > 31) return null;
      if (year < 1900 || year > DateTime.now().year) return null;
      
      final date = DateTime(year, month, day);
      
      // Kiểm tra ngày hợp lệ (ví dụ: 31/02 không tồn tại)
      if (date.year != year || date.month != month || date.day != day) {
        return null;
      }
      
      // Kiểm tra không được là tương lai
      if (date.isAfter(DateTime.now())) return null;
      
      return date;
    } catch (e) {
      return null;
    }
  }

  void _onDateTextChanged(String value) {
    final parsedDate = _parseDateFromString(value);
    setState(() {
      _selectedDate = parsedDate;
    });
  }

  String? _validateCustomerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên khách hàng';
    }
    if (value.trim().length < 2) {
      return 'Tên khách hàng phải có ít nhất 2 ký tự';
    }
    // Kiểm tra chỉ chứa chữ cái, khoảng trắng và dấu
    if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(value.trim())) {
      return 'Tên khách hàng chỉ được chứa chữ cái và khoảng trắng';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    // Loại bỏ khoảng trắng và dấu cách
    final phone = value.replaceAll(RegExp(r'\s+'), '');
    // Kiểm tra format số điện thoại Việt Nam (10 số, bắt đầu bằng 0)
    if (!RegExp(r'^0\d{9}$').hasMatch(phone)) {
      return 'Số điện thoại không hợp lệ (ví dụ: 0901234567)';
    }
    return null;
  }


  String? _validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số tài khoản';
    }
    // Loại bỏ khoảng trắng
    final accountNumber = value.replaceAll(RegExp(r'\s+'), '');
    // Chỉ chứa số
    if (!RegExp(r'^\d+$').hasMatch(accountNumber)) {
      return 'Số tài khoản chỉ được chứa số';
    }
    // Độ dài tối thiểu 8 số
    if (accountNumber.length < 8) {
      return 'Số tài khoản phải có ít nhất 8 chữ số';
    }
    // Độ dài tối đa 20 số
    if (accountNumber.length > 20) {
      return 'Số tài khoản không được vượt quá 20 chữ số';
    }
    return null;
  }

  bool _isFormValid() {
    return _validateCustomerName(_customerNameController.text) == null &&
        _validatePhone(_phoneController.text) == null &&
        _dateController.text.trim().isNotEmpty &&
        _selectedBank != null &&
        _validateAccountNumber(_accountNumberController.text) == null;
  }

  void _handlePayment(BuildContext context) async {
    if (_formKey.currentState!.validate() && _isFormValid()) {
      // Tính tổng số lượng sản phẩm đã thanh toán
      final totalQuantity = widget.selectedItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

      // Xóa các sản phẩm đã chọn khỏi giỏ hàng
      final cartService = CartService();
      cartService.clearSelectedItems();

      // Tăng số sản phẩm đã mua
      await PurchaseService.addPurchasedCount(totalQuantity);

      // Quay về trang cart (pop về màn hình trước đó)
      Navigator.of(context).pop(true);

      // Hiển thị thông báo thanh toán thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.selectedItems.fold(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tên khách hàng
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên khách hàng',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Nhập họ và tên',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: _validateCustomerName,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    // Số điện thoại
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: '0901234567',
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: _validatePhone,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    // Ngày sinh
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Ngày sinh',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        hintText: 'DD/MM/YYYY (ví dụ: 17/11/2004)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                          tooltip: 'Chọn ngày từ lịch',
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        DateInputFormatter(),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      onChanged: _onDateTextChanged,
                    ),
                    const SizedBox(height: 16),
                    // Ngân hàng giao dịch
                    DropdownButtonFormField<String>(
                      value: _selectedBank,
                      decoration: const InputDecoration(
                        labelText: 'Ngân hàng giao dịch',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      hint: const Text('Chọn ngân hàng'),
                      items: _banks.map((String bank) {
                        return DropdownMenuItem<String>(
                          value: bank,
                          child: Text(bank),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBank = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Số tài khoản
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Số tài khoản',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                        hintText: 'Nhập số tài khoản (8-20 số)',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 20,
                      validator: _validateAccountNumber,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tổng tiền và nút thanh toán
          _buildBottomBar(context, totalPrice),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, double totalPrice) {
    final isValid = _isFormValid();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_formatPrice(totalPrice)} đ',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValid
                    ? () => _handlePayment(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text(
                  'Thanh toán',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
