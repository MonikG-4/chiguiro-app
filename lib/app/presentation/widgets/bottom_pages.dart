import 'package:flutter/material.dart';
import '../../../../core/values/app_colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 27),
      child: const Text(
        "CHIGÜIRO | SAS DATA COLLECT",
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.secondary, fontSize: 13),
      ),
    );
  }
}