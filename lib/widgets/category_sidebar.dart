import 'package:flutter/material.dart';

class CategorySidebar extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySidebar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final expandedWidth = screenWidth / 4; // 1/4 chiều rộng màn hình
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isExpanded ? expandedWidth : 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Icon danh mục - luôn hiển thị
          InkWell(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Icon(
                isExpanded ? Icons.arrow_back_ios : Icons.menu,
                size: 24,
              ),
            ),
          ),
          // Danh sách danh mục - chỉ hiển thị khi expanded
          if (isExpanded) ...[
            _buildCategoryItem('Honda', Icons.motorcycle, 0),
            _buildCategoryItem('Xe điện', Icons.electric_car, 1),
            _buildCategoryItem('Yamaha', Icons.two_wheeler, 2),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, int index) {
    final isSelected = selectedCategory == label;
    return InkWell(
      onTap: () {
        onCategorySelected(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        color: isSelected ? Colors.orange.withOpacity(0.2) : Colors.transparent,
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.orange : Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.orange : Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

