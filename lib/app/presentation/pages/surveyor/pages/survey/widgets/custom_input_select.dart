import 'package:flutter/material.dart';
import '../../../../../../../core/theme/app_colors_theme.dart';

class CustomInputSelect extends StatelessWidget {
  final bool hasError;
  final bool hasValue;
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool? isSelected;

  const CustomInputSelect({
    super.key,
    required this.hasError,
    required this.hasValue,
    required this.children,
    this.onTap,
    this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: (isSelected != null)
              ? isSelected!
                  ? scheme.selectBackground
                  : Colors.transparent
              : Colors.transparent,
          border: Border.all(
            color: hasError
                ? Colors.red
                : hasValue && isSelected == null
                    ? AppColorScheme.primary
                    : (isSelected ?? false)
                        ? AppColorScheme.primary
                        : scheme.secondaryText,
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
