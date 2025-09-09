import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors_theme.dart';

class CustomCard extends StatelessWidget {
  final List<Widget> children;
  final Color? color;
  final EdgeInsets? padding;

  const CustomCard({
    required this.children,
    this.color,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}