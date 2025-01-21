import 'package:flutter/material.dart';
import '../../../../../core/utils/validator_login_fields.dart';
import '../../../widgets/custom_text_field.dart';

class ChangePasswordForm extends StatefulWidget {
  final TextEditingController passwordController;

  const ChangePasswordForm ({
    super.key,
    required this.passwordController,
  });

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  bool obscureText = true;

  @override
  void dispose() {
    widget.passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputField<String>(
          label: 'Nueva contraseña*',
          hintText: 'Ingresa tu contraseña',
          controller: widget.passwordController,
          obscureText: obscureText,
          validator: (value) {
            return ValidatorLoginFields.validatePassword(value ?? '');
          },
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        CustomInputField<String>(
          label: 'Confirmar contraseña*',
          hintText: 'Ingresa tu contraseña',
          controller: widget.passwordController,
          obscureText: obscureText,
          validator: (value) {
            return ValidatorLoginFields.validatePassword(value ?? '');
          },
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
          ),
        ),
      ],
    );
  }
}
