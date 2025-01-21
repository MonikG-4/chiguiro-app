import 'package:flutter/material.dart';
import '../../../../../core/utils/validator_login_fields.dart';
import '../../../widgets/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscureText = true;

  @override
  void dispose() {
    widget.emailController.dispose();
    widget.passwordController.dispose();
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
        const SizedBox(height: 16),
        CustomInputField<String>(
          label: 'Contraseña*',
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
