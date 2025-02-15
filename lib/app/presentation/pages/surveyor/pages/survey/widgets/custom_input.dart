import 'package:flutter/material.dart';
import '../../../../../../../../core/values/app_colors.dart';

class CustomInput extends StatelessWidget {
  final bool hasError;
  final bool hasValue;
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool? isSelected;

  const CustomInput({
    super.key,
    required this.hasError,
    required this.hasValue,
    required this.children,
    this.onTap,
    this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (isSelected != null)
              ? isSelected!
                  ? AppColors.successBackground
                  : Colors.transparent
              : Colors.transparent,
          border: Border.all(
            color: hasError
                ? Colors.red
                : hasValue && isSelected == null
                    ? AppColors.successBorder
                    : (isSelected ?? false)
                        ? AppColors.successBorder
                        : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children),
      ),
    );
  }
}
