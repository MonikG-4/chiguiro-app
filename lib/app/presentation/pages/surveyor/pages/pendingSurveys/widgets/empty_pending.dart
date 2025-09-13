import 'package:flutter/material.dart';

import '../../../../../../../core/theme/app_colors_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Column(
          children: [
            const Icon(Icons.access_time_rounded,
                size: 92, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Encuestas pendientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Aquí se guardarán las encuestas que no pudieron enviarse por falta de conexión. '
                  'Se enviarán automáticamente al reconectarte o puedes subirlas manualmente con el botón.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.secondaryText, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}
