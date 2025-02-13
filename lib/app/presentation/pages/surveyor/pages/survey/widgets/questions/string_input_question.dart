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
  _StringInputQuestionState createState() => _StringInputQuestionState();
}

class _StringInputQuestionState extends State<StringInputQuestion> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.controller.responses[widget.question.id]?['value'] ?? '',
    );

    _textController.addListener(() {
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
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant StringInputQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentValue = widget.controller.responses[widget.question.id]?['value'] ?? '';
    if (currentValue != _textController.text) {
      _textController.text = currentValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: (value) {
        final error = widget.controller.validatorMandatory(widget.question)(value);
        if (error != null && _textController.text.isNotEmpty) {
          return null;
        }
        return error;
      },
      builder: (FormFieldState<String> state) {
        return Obx(() {
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
}
