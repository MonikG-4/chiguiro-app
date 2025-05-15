import 'package:flutter/material.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_input.dart';

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
      validator: (value) {
        final error = widget.controller.validatorMandatory(widget.question)(_textController.text);
        if (error != null && _textController.text.isNotEmpty) {
          return null;
        }
        return error;
      },
      builder: (FormFieldState<String> state) {

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInput(
                controller: _textController,
                inputType: InputValueType.integer,
                hintText: 'Ejemplo: 10',
                errorText: state.errorText,
                onChanged: (value) {
                  state.validate();
                },
              ),
            ],
          );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
