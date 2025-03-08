import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../../../../core/values/app_colors.dart';

class MatrixCell extends StatefulWidget {
  final TextEditingController controller;
  final String hinText;
  final ValueChanged<String> onChanged;

  const MatrixCell({
    super.key,
    required this.controller,
    required this.hinText,
    required this.onChanged,
  });

  @override
  State<MatrixCell> createState() => _MatrixCellState();
}

class _MatrixCellState extends State<MatrixCell> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.hinText == '' ? 50 : 100,
      child: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: (value) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 400), () {
            widget.onChanged(value);
          });
        },

        decoration: InputDecoration(
          hintText: widget.hinText,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.controller.value.text.isEmpty ? Colors.grey[300]! : AppColors.successBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: widget.controller.value.text.isEmpty ? Colors.grey[300]! : AppColors.successBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.successBorder),
          ),
        ),
      ),
    );
  }
}
