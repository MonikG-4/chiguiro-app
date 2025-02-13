import 'package:chiguiro_front_app/core/values/app_colors.dart';
import 'package:flutter/material.dart';

class CustomInputField<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final T? initialValue;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;

  const CustomInputField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.initialValue,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.secondary),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          initialValue: initialValue?.toString(),
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}