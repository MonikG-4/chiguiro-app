import 'package:flutter/material.dart';

import '../../../core/values/app_colors.dart';

class CustomTextButtonRedirect extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final TextStyle? style;
  final Alignment alignment;

  const CustomTextButtonRedirect({
    super.key,
    required this.onPressed,
    required this.label,
    this.style,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: TextButton(
        onPressed: onPressed,
        child: Text( // `child` is correct here
          label,
          style: style ?? const TextStyle(color: AppColors.tertiary), // Default style
        ),
      ),
    );
  }
}