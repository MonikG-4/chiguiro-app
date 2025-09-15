import 'package:flutter/material.dart';
import '../../../core/theme/app_colors_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String? message;
  final Widget? content;
  final String title;
  final bool centerTitle;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showActions;

  const ConfirmationDialog({
    super.key,
    this.message,
    this.content,
    this.title = 'Confirmación',
    this.centerTitle = false,
    this.confirmText = 'Continuar',
    this.cancelText = 'Cancelar',
    this.onConfirm,
    this.onCancel,
    this.showActions = true,
  }) : assert(
  message != null || content != null,
  'Debes proveer "message" o "content" en ConfirmationDialog.',
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.secondBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.border.withOpacity(isDark ? 0.28 : 0.55),
          ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ).copyWith(color: scheme.onFirstBackground),
                textAlign: centerTitle ? TextAlign.center : null,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content ??
                  Text(
                    message!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                    ).copyWith(color: scheme.secondaryText),
                  ),
            ),

            if (showActions) ...[
              Container(
                height: 1,
                color: scheme.border.withOpacity(isDark ? 0.32 : 0.6),
              ),

              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                        onTap: () {
                          onCancel?.call();
                          Navigator.of(context).pop(false);
                        },
                        child: Center(
                          child: Text(
                            cancelText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ).copyWith(color: scheme.secondaryText),
                          ),
                        ),
                      ),
                    ),

                    Container(
                      width: 1,
                      color: scheme.border.withOpacity(isDark ? 0.32 : 0.6),
                    ),

                    Expanded(
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                        onTap: () {
                          onConfirm?.call();
                          Navigator.of(context).pop(true);
                        },
                        child: Center(
                          child: Text(
                            confirmText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ).copyWith(color: scheme.iconBackground),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
