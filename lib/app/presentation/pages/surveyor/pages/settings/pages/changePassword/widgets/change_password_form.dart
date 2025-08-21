import 'package:flutter/material.dart';

import '../../../../../../../../../core/utils/validator_login_fields.dart';
import '../../../../../../../widgets/custom_text_field.dart';


class ChangePasswordForm extends StatefulWidget {
  final TextEditingController passwordController;

  const ChangePasswordForm({
    super.key,
    required this.passwordController,
  });

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  bool obscureTextPassword = true;
  bool obscureTextConfirmPassword = true;  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    widget.passwordController.dispose();
    confirmPasswordController.dispose();
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
          obscureText: obscureTextPassword,
          validator: (value) {
            return ValidatorLoginFields.validatePassword(value ?? '');
          },
          suffixIcon: IconButton(
            icon: Icon(obscureTextPassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                obscureTextPassword = !obscureTextPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        CustomInputField<String>(
          label: 'Confirmar contraseña*',
          hintText: 'Ingresa tu contraseña',
          controller: confirmPasswordController,
          obscureText: obscureTextConfirmPassword,
          validator: (value) {
            return ValidatorLoginFields.confirmPassword(widget.passwordController.text, value ?? '');
          },
          suffixIcon: IconButton(
            icon: Icon(obscureTextConfirmPassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                obscureTextConfirmPassword = !obscureTextConfirmPassword;
              });
            },
          ),
        ),
      ],
    );
  }
}