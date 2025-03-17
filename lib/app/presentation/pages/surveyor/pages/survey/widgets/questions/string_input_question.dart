import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/values/app_colors.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';

class StringInputQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const StringInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  StringInputQuestionState createState() => StringInputQuestionState();
}

class StringInputQuestionState extends State<StringInputQuestion> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _updateControllerText();
    _textController.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant StringInputQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateControllerText();
  }

  void _updateControllerText() {
    final currentValue = widget.controller.responses[widget.question.id]?['value'] ?? '';
    if (_textController.text != currentValue) {
      _textController.text = currentValue;
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
    }
  }

  void _onTextChanged() {
    final value = _textController.text;
    if (value.isEmpty) {
      widget.controller.responses.remove(widget.question.id);
    } else {
      widget.controller.responses[widget.question.id] = {
        'question': widget.question.question,
        'type': widget.question.type,
        'value': value,
      };
    }
    widget.controller.responses.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      key: ValueKey(widget.question.id),
      validator: widget.controller.validatorMandatory(widget.question),
      builder: (FormFieldState<String> state) {
        return Obx(() {
          _updateControllerText();

          final hasValue = widget.controller.responses[widget.question.id]?['value'] != null;

          return TextFormField(
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              errorText: state.errorText,
            ),
            onChanged: (value) {
              state.validate();
            },
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
