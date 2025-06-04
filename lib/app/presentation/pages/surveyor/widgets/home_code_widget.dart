import 'package:flutter/material.dart';
import '../../../../../core/values/app_colors.dart';

class HomeCodeWidget extends StatelessWidget {
  final String homeCode;
  final bool readOnly;

  const HomeCodeWidget({
    super.key,
    required this.homeCode,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCode = homeCode.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          const Text(
            'Código de hogar',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: hasCode ? AppColors.codeBackground : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hasCode ? homeCode : "---- ----",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
