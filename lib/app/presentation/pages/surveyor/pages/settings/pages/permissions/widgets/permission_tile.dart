import 'package:flutter/material.dart';

import '../../../../../../../../../core/theme/app_colors_theme.dart';

class PermissionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool status;
  final VoidCallback onTap;

  const PermissionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.secondBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: scheme.secondaryText),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 16)),
              ),
              Text(
                status ? 'Permitido' : 'No permitido',
                style: TextStyle(
                  fontSize: 14,
                  color: status ? Colors.green : Colors.grey,
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
