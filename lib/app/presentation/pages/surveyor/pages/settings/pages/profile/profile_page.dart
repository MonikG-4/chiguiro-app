import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/services/auth_storage_service.dart';
import '../../../../../../../../core/theme/app_colors_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthStorageService>().authResponse!;
    final scheme = Theme.of(context).extension<AppColorScheme>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Información Personal",
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: scheme.iconBackground, // acento de marca
              child: const Icon(Icons.person, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),

            _buildTextField(
              context: context,
              label: 'Nombre',
              initialValue: user.name,
            ),
            const SizedBox(height: 12),

            _buildTextField(
              context: context,
              label: 'Apellido',
              initialValue: user.surname,
            ),
            const SizedBox(height: 12),

            _buildTextField(
              context: context,
              label: 'Correo',
              initialValue: user.email,
            ),
            const SizedBox(height: 12),

            _buildPhoneField(context, user.phone),
          ],
        ),
      ),
    );
  }

  // ------------ helpers ------------

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String initialValue,
  }) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      initialValue: initialValue,
      readOnly: true,
      style: textTheme.bodyMedium?.copyWith(
        color: scheme.secondaryText,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        // Dejamos que el Theme maneje borders; solo afinamos colores del label y el fill
        labelStyle: TextStyle(color: scheme.secondaryText),
        filled: true,
        fillColor: scheme.secondBackground, // match con tu paleta (Select)
        enabledBorder: _border(context),
        focusedBorder: _focusedBorder(context),
      ),
    );
  }

  Widget _buildPhoneField(BuildContext context, String initialValue) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      initialValue: initialValue,
      readOnly: true,
      style: textTheme.bodyMedium?.copyWith(
        color: scheme.secondaryText,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Número Telefónico',
        labelStyle: TextStyle(color: scheme.secondaryText),
        filled: true,
        fillColor: scheme.secondBackground,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefix: Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: scheme.border, width: 1.5),
            ),
          ),
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/co.png', width: 24, height: 24),
              const SizedBox(width: 6),
              Text(
                '+57',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onFirstBackground,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        enabledBorder: _border(context),
        focusedBorder: _focusedBorder(context),
      ),
    );
  }

  OutlineInputBorder _border(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.border.withOpacity(0.0)), // sin borde visible
    );
  }

  OutlineInputBorder _focusedBorder(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? scheme.iconBackground : AppColorScheme.focusBorder,
        width: 1.2,
      ),
    );
  }
}
