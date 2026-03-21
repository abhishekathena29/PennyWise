import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: inputDecoration(label, hint: hint),
    );
  }
}

InputDecoration inputDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label.isEmpty ? null : label,
    hintText: hint,
    filled: true,
    fillColor: AppTheme.card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppTheme.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppTheme.border),
    ),
  );
}
