import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import 'package:chiguiro_front_app/core/values/app_colors.dart';

class PhotoInputQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const PhotoInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  PhotoInputQuestionState createState() => PhotoInputQuestionState();
}

class PhotoInputQuestionState extends State<PhotoInputQuestion> {
  @override
  Widget build(BuildContext context) {
    return FormField<File?>(
      key: ValueKey('photo_${widget.question.id}'),
      validator: widget.controller.validatorMandatory(widget.question),
      builder: (FormFieldState<File?> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => widget.controller.imageFile.value == null
                  ? SizedBox(
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, color: Colors.grey, size: 40),
                                    Text("No se ha capturado una imagen"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: Container(
                        height: 350,
                        width: 350,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.successBorder),
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image:
                                FileImage(widget.controller.imageFile.value!),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                await widget.controller.pickImage(widget.question);
                state.didChange(widget.controller.imageFile.value);
                state.validate();
              },
              icon: Icon(Icons.camera_alt,
                  color: state.hasError
                      ? AppColors.errorText
                      : AppColors.successText),
              label: const Text("Tomar Foto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: state.hasError
                    ? AppColors.errorBackground
                    : AppColors.successBackground,
                foregroundColor: state.hasError
                    ? AppColors.errorText
                    : AppColors.successText,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }
}
