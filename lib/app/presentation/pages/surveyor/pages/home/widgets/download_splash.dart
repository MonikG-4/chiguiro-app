import 'package:flutter/material.dart';

class DownloadSplash extends StatelessWidget {
  const DownloadSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00695C), // color de fondo
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stack para superponer el loader circular sobre la imagen
            Stack(
              alignment: Alignment.center,
              children: [
                // Loader circular animado
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                // Imagen en el centro
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                      'assets/images/icon.png', // Verificar esta ruta
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Widget de fallback si la imagen no se puede cargar
                        return const Icon(
                          Icons.app_registration,
                          size: 40,
                          color: Color(0xFF00695C),
                        );
                      },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Espera un momento...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Se están descargando encuestas.\nSi sales ahora, no podrás acceder a ellas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}