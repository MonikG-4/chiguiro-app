import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import 'package:chiguiro_front_app/core/theme/app_colors_theme.dart';

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
  final RxList<File> _localImages = <File>[].obs;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    final savedImages =
    widget.controller.responses[widget.question.id]?['value'] as List<File>?;
    if (savedImages != null) {
      _localImages.assignAll(savedImages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<File>>(
      key: ValueKey('photo_${widget.question.id}'),
      validator: widget.controller.validatorMandatory(widget.question),
      builder: (FormFieldState<List<File>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => _buildPhotoSection(state.hasError)),
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

  Widget _buildPhotoSection(bool state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildUploadButton(state),
          const SizedBox(width: 10),
          _buildImagePreview(),
        ],
      ),
    );
  }

  Widget _buildUploadButton(bool state) {
    return GestureDetector(
      onTap: () async {
        await widget.controller.pickImage(widget.question);
        _localImages.value =
        List<File>.from(widget.controller.responses[widget.question.id]?['value'] ?? []);
        widget.controller.responses.refresh();
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: state ? AppColorScheme.primary : Colors.grey, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.black54, size: 40),
            SizedBox(height: 5),
            Text("Cargar foto", style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _localImages.map((file) {
        return Stack(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: AppColorScheme.primary),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: FileImage(file),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: () {
                  _localImages.remove(file);
                  widget.controller.responses[widget.question.id]?['value'] = _localImages;
                  widget.controller.responses.refresh();
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
