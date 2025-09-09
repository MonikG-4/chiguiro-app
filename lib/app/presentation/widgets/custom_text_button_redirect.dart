import 'package:flutter/material.dart';

import '../../../core/theme/app_colors_theme.dart';

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
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Align(
      alignment: alignment,
      child: TextButton(
        onPressed: onPressed,
        child: Text( // `child` is correct here
          label,
          style: style ?? const TextStyle(color: AppColorScheme.primary,), // Default style
        ),
      ),
    );
  }
}