import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final Widget? icon;

  final double? textSize;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final double? borderRadius;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.icon,
    this.textSize,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: borderRadius != null
              ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius!),
          )
              : null,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: textSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
