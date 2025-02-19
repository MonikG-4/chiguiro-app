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
  String? _lastValue;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.controller.responses[widget.question.id]?['value'];
    _textController = TextEditingController(
      text: initialValue != null && initialValue != 0 ? initialValue.toString() : '',
    );
    _textController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant DecimalInputQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentValue = widget.controller.responses[widget.question.id]?['value'];
    final currentText = currentValue != null && currentValue != 0.0
        ? currentValue.toString()
        : '';

    if (_textController.text != currentText) {
      _textController.text = currentText;
    }
  }

  void _onTextChanged() {
    final value = _parseDecimal(_textController.text);

    if (_lastValue == _textController.text) return;

    if (value != null && value != 0.0) {
      widget.controller.responses[widget.question.id] = {
        'question': widget.question.question,
        'type': widget.question.type,
        'value': double.tryParse(value.toString()),
      };
    } else {
      widget.controller.responses.remove(widget.question.id);
    }

    _lastValue = _textController.text;
  }

  double? _parseDecimal(String value) {
    String cleanValue = value.replaceAll(',', '');
    return double.tryParse(cleanValue);
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
              ),
            ],
          );
        });
      },
    );
  }
}
