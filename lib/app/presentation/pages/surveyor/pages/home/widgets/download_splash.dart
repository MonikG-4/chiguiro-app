import 'package:flutter/material.dart';

import '../../../../../../../core/theme/app_colors_theme.dart';

class DownloadSplash extends StatelessWidget {
  const DownloadSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).extension<AppColorScheme>()!.onFirstBackground,
                    ),
                    backgroundColor: Theme.of(context).extension<AppColorScheme>()!.onFirstBackground.withOpacity(0.3),
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.app_registration, size: 40);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    'Espera un momento...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Se están descargando encuestas. Si sales ahora, no podrás acceder a ellas.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
