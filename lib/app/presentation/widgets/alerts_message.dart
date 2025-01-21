import 'dart:async';
import 'package:chiguiro_front_app/core/values/app_colors.dart';
import 'package:flutter/material.dart';

class AlertMessage<T> extends StatefulWidget {
  final T controller;

  const AlertMessage({
    super.key,
    required this.controller,
  });

  @override
  _AlertMessageState<T> createState() => _AlertMessageState<T>();
}

class _AlertMessageState<T> extends State<AlertMessage<T>> {
  late Timer _timer;
  bool _isVisible = false;

  static const Map<String, Map<String, dynamic>> typeAlert = {
    'Text': {
      'success': AppColors.successText,
      'error': AppColors.errorText,
      'warning': AppColors.warningText,
    },
    'Background': {
      'success': AppColors.successBackground,
      'error': AppColors.errorBackground,
      'warning': AppColors.warningBackground,
    },
    'Border': {
      'success': AppColors.successBorder,
      'error': AppColors.errorBorder,
      'warning': AppColors.warningBorder,
    },
    'Icon': {
      'success': Icons.check_circle,
      'error': Icons.error,
      'warning': Icons.warning,
    },
  };

  @override
  void initState() {
    super.initState();
    _isVisible = true;
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        (widget.controller as dynamic).deleteMessage();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = (widget.controller as dynamic).messageValue;
    final state = (widget.controller as dynamic).stateMessageValue;

    return _isVisible && message.isNotEmpty
        ? Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        decoration: BoxDecoration(
          color: typeAlert["Background"]![state],
          border: Border.all(
            color: typeAlert["Border"]![state],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              typeAlert["Icon"]![state],
              color: typeAlert["Text"]![state],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: typeAlert["Text"]![state],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ))
        : const SizedBox.shrink();
  }
}