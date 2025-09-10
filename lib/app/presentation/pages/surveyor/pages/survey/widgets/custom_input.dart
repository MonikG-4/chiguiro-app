import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../../core/theme/app_colors_theme.dart';

enum InputValueType { text, integer, decimal }

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final InputValueType inputType;
  final String? hintText;
  final String? errorText;

  const CustomInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.inputType = InputValueType.text,
    this.hintText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return TextFormField(
      controller: controller,
      keyboardType: _getKeyboardType(),
      inputFormatters: _getInputFormatters(),
      decoration: InputDecoration(
        fillColor: scheme.firstBackground,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: controller.text.isNotEmpty ? AppColorScheme.primary : scheme.border,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColorScheme.primary),
          borderRadius: BorderRadius.circular(8.0),
        ),
        hintText: hintText ?? _getDefaultHint(),
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      onChanged: onChanged,
    );
  }

  TextInputType _getKeyboardType() {
    switch (inputType) {
      case InputValueType.integer:
        return TextInputType.number;
      case InputValueType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? _getInputFormatters() {
    switch (inputType) {
      case InputValueType.integer:
        return [FilteringTextInputFormatter.digitsOnly];
      case InputValueType.decimal:
        return [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
      default:
        return null;
    }
  }

  String? _getDefaultHint() {
    switch (inputType) {
      case InputValueType.integer:
        return 'Ejemplo: 10';
      case InputValueType.decimal:
        return 'Ejemplo: 5.5';
      default:
        return null;
    }
  }
}
