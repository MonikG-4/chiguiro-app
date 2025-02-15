import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../../../../../core/values/app_colors.dart';

class MatrixCell extends StatefulWidget {
  final String initialValue;
  final String hinText;
  final ValueChanged<String> onChanged;

  const MatrixCell({
    super.key,
    required this.initialValue,
    required this.hinText,
    required this.onChanged,
  });

  @override
  State<MatrixCell> createState() => MatrixCellState();
}

class MatrixCellState extends State<MatrixCell> {
  late final TextEditingController _controller;
  bool isFilled = false;
  String _lastValue = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    isFilled = widget.initialValue.isNotEmpty;
    _lastValue = widget.initialValue;
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    if (_lastValue != value) {
      setState(() {
        isFilled = value.isNotEmpty;
      });

      _lastValue = value;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        widget.onChanged(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onChanged: _onTextChanged,
        decoration: InputDecoration(
          hintText: widget.hinText,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isFilled ? AppColors.successBorder : Colors.grey[300]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: isFilled ? AppColors.successBorder : Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: AppColors.successBorder,
            ),
          ),
        ),
      ),
    );
  }
}