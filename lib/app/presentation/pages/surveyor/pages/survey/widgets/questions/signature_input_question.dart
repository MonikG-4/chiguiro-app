import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../../../../../../core/values/app_colors.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';

class SignatureInputQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const SignatureInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<SignatureInputQuestion> createState() => _SignatureInputQuestionState();
}

class _SignatureInputQuestionState extends State<SignatureInputQuestion> {
  final RxBool isLocked = false.obs;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();

    // Escucha cada vez que termina un trazo
    _signatureController.onDrawEnd = () async {
      if (!_signatureController.isEmpty && !isLocked.value) {
        await widget.controller.saveSignature(
          widget.question,
          _signatureController,
        );
        isLocked.value = true;
      }
    };
  }

  void _clearSignature() {
    _signatureController.clear();
    isLocked.value = false;
    widget.controller.responses.remove(widget.question.id);
    widget.controller.responses.refresh();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasSignature =
      widget.controller.responses.containsKey(widget.question.id);
      final borderColor =
      hasSignature ? AppColors.successBorder : AppColors.inputs;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: AbsorbPointer(
                  absorbing: isLocked.value,
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: AppColors.background,
                  ),
                ),
              ),
              if (isLocked.value)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: _clearSignature,
                    icon: const Icon(Icons.clear, size: 20),
                    color: Colors.grey[700],
                    tooltip: 'Limpiar firma',
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}
