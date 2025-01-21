import 'package:flutter/material.dart';
import '../../../../../core/utils/validator_login_fields.dart';
import '../../../widgets/custom_text_field.dart';

class ForgotPasswordForm extends StatefulWidget {
  final TextEditingController emailController;

  const ForgotPasswordForm ({
    super.key,
    required this.emailController,
  });

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  bool obscureText = true;

  @override
  void dispose() {
    widget.emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputField<String>(
          label: 'Correo electrónico*',
          hintText: 'Ingresa tu correo',
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            return ValidatorLoginFields.validateEmail(value ?? '');

          },
        ),
      ],
    );
  }
}
