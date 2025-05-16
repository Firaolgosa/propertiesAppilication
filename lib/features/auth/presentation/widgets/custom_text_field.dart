import 'package:flutter/material.dart';
import 'package:properties/core/utils/colors.dart';
import 'package:properties/core/utils/styles.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final String? helperText;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.helperText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppStyles.bodyMedium,
      decoration: AppStyles.textFieldDecoration.copyWith(
        hintText: hintText,
        helperText: helperText,
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.textSecondaryColor,
        ),
      ),
    );
  }
}
