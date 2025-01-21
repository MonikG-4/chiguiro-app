import 'package:flutter/material.dart';

import 'app_logo.dart';

class CustomViewForm extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final Widget title;
  final String? subtitle;
  final Widget form;
  final Widget? buttonText;
  final Widget? textButton;
  final Widget? message;

  const CustomViewForm({
    super.key,
    required this.formKey,
    required this.title,
    this.subtitle,
    required this.form,
    this.buttonText,
    this.textButton,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppLogo(),
                title,
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],

                if (message != null ) ...[
                  const SizedBox(height: 4),
                  message!,
                  const SizedBox(height: 4),
                ],
                form,

                if (textButton != null) ...[
                  textButton!,
                ],
                if (buttonText != null) ...[
                  buttonText!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
