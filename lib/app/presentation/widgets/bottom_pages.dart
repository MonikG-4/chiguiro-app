import 'package:flutter/material.dart';
import '../../../core/theme/app_colors_theme.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Container(
      padding: const EdgeInsets.only(bottom: 27),
      child: Text(
        "CHIGÜIRO | SAS DATA COLLECT",
        textAlign: TextAlign.center,
        style: TextStyle(color: scheme.secondaryText, fontSize: 13),
      ),
    );
  }
}