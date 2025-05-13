import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/values/app_colors.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';

class IntegerInputQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const IntegerInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<IntegerInputQuestion> createState() => _IntegerInputQuestionState();
}

class _IntegerInputQuestionState extends State<IntegerInputQuestion> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _updateControllerText();
    _textController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant IntegerInputQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateControllerText();
  }

  void _updateControllerText() {
    final currentValue = widget.controller.responses[widget.question.id]?['value'];
    final currentText = currentValue != null
        ? currentValue.toString()
        : '';

    if (_textController.text != currentText) {
      _textController.text = currentText;
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
    }
  }

  void _onTextChanged() {
    final value = _textController.text;

    widget.controller.responses[widget.question.id] = {
      'question': widget.question.question,
      'type': widget.question.type,
      'value': value,
    };
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
          _updateControllerText();

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
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
