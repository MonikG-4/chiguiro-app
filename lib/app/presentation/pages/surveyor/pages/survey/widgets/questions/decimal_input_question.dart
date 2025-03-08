import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/values/app_colors.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';

class DecimalInputQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const DecimalInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<DecimalInputQuestion> createState() => _DecimalInputQuestionState();
}

class _DecimalInputQuestionState extends State<DecimalInputQuestion> {
  late final TextEditingController _textController;
  bool _isUserTyping = false;
  late final Worker _responseWorker;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _updateControllerText();
    _textController.addListener(_onTextChanged);

    // Añadir un worker para observar cambios en responses
    _responseWorker = ever(
        widget.controller.responses,
            (_) => _handleResponsesChange()
    );
  }

  void _handleResponsesChange() {
    if (!_isUserTyping) {
      _updateControllerText();
    }
  }

  @override
  void didUpdateWidget(covariant DecimalInputQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isUserTyping) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final currentValue = widget.controller.responses[widget.question.id]?['value'];
    final currentText = currentValue != null ? currentValue.toString() : '';

    if (_textController.text != currentText) {
      _textController.text = currentText;
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
    }
  }

  void _onTextChanged() {
    _isUserTyping = true;
    final value = _textController.text;

    if (value.isNotEmpty) {
      final parsedValue = double.tryParse(value.replaceAll(',', ''));
      if (parsedValue != null) {
        widget.controller.responses[widget.question.id] = {
          'question': widget.question.question,
          'type': widget.question.type,
          'value': value.contains('.') ? parsedValue : '${parsedValue.toInt()}.0',
        };
      }
    } else {
      widget.controller.responses.remove(widget.question.id);
    }
    widget.controller.responses.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: (value) {
        final error = widget.controller.validatorMandatory(widget.question)(_textController.text);
        if (error != null && _textController.text.isNotEmpty) {
          return null;
        }
        return error;
      },
      builder: (FormFieldState<String> state) {
        return Obx(() {
          final hasValue = widget.controller.responses[widget.question.id]?['value'] != null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: hasValue ? AppColors.successBorder : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.successBorder),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorText: state.errorText,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                onChanged: (value) {
                  state.validate();
                },
                onEditingComplete: () {
                  _isUserTyping = false;
                  FocusScope.of(context).unfocus(); // Ocultar teclado
                  _updateControllerText();
                },
                // Añadir TextInputAction explícitamente
                textInputAction: TextInputAction.done,

              ),
            ],
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _responseWorker.dispose(); // Importante: limpiar el worker
    _textController.dispose();
    super.dispose();
  }
}