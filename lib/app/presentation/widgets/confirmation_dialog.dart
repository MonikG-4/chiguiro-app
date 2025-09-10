import 'package:flutter/material.dart';
import '../../../core/theme/app_colors_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final String title;
  final String confirmText;
  final String cancelText;

  const ConfirmationDialog({
    super.key,
    required this.message,
    this.title = 'Confirmación',
    this.confirmText = 'Continuar',
    this.cancelText = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.secondBackground, // card
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.border.withOpacity(isDark ? 0.28 : 0.55)),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : scheme.border)
                  .withOpacity(isDark ? 0.40 : 0.20),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onFirstBackground,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            // Mensaje
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.secondaryText,
                  height: 1.35,
                ),
              ),
            ),

            // Línea separadora superior
            Container(height: 1, color: scheme.border.withOpacity(isDark ? 0.32 : 0.6)),

            // Acciones estilo iOS
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  // Cancelar
                  Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                      ),
                      onTap: () => Navigator.of(context).pop(false),
                      child: Center(
                        child: Text(
                          cancelText,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Separador vertical
                  Container(
                    width: 1,
                    color: scheme.border.withOpacity(isDark ? 0.32 : 0.6),
                  ),

                  // Confirmar
                  Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                      onTap: () => Navigator.of(context).pop(true),
                      child: Center(
                        child: Text(
                          confirmText,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: scheme.iconBackground, // “azul iOS”
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
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
