import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        onChanged: onChanged,
        onSubmitted: (_) => onSearch?.call(),
        decoration: InputDecoration(
          hintText: 'search',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}

