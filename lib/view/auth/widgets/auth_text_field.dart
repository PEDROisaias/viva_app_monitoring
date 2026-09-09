
import 'package:flutter/material.dart';
import '../../../res/style/app_theme.dart';
 
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
 
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });
 
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: TextStyle(
        color: AM032Colors.textPrimary,
        fontSize: 15,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: AM032Colors.textSecondary,
          fontSize: 13,
        ),
        hintStyle: TextStyle(
          color: AM032Colors.textSecondary.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: AM032Colors.textSecondary,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AM032Colors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AM032Colors.bgElevated,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AM032Colors.statusGood,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AM032Colors.statusDanger.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AM032Colors.statusDanger,
            width: 1.5,
          ),
        ),
        errorStyle: TextStyle(
          color: AM032Colors.statusDanger,
          fontSize: 12,
        ),
      ),
    );
  }
}