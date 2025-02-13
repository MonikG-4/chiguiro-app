import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/values/app_colors.dart';
import '../../../../../domain/entities/auth_response.dart';
import '../../../../../domain/entities/survey.dart';
import '../../../../../presentation/controllers/survey_controller.dart';
import '../../../../controllers/auth_storage_controller.dart';
import 'widgets/custom_progress_bar.dart';
import 'widgets/keep_alive_survey_question.dart';
import 'widgets/question_widget_factory.dart';

class SurveyPage extends StatelessWidget {
  final Survey survey;
  final AuthResponse authResponse;
  final SurveyController controller = Get.find();

  SurveyPage({super.key})
      : survey = Get.arguments,
        authResponse = Get.find<AuthStorageController>().authResponse.value!;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.fetchSurveyQuestions(survey.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(survey.name),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: AppColors.background,
      body: Obx(
            () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            _buildQuestionsForm(),
            _buildProgressBar(),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0, bottom: 80.0),
      child: Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: controller.questions.length,
          itemBuilder: (context, index) {
            final question = controller.questions[index];
            return KeepAliveSurveyQuestion(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: QuestionWidgetFactory.createQuestionWidget(question),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Obx(
            () {
              final totalQuestions = controller.questions.length;
              final answeredQuestions = controller.responses.length;
              final progress =
              totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

              return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[300],
                      ),
                    ),
                    CustomProgressBar(progress: progress),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitSurvey,
          child: const Text("Enviar Encuesta"),
        ),
      ),
    );
  }

  void _submitSurvey() {
    if (_validateAllQuestions()) {
      controller.getSurveyResults(survey.id, authResponse.id);
    } else {
      Get.snackbar(
        'Error',
        'Por favor responde todas las preguntas obligatorias',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  bool _validateAllQuestions() {
    if (!_formKey.currentState!.validate()) return false;

    for (var question in controller.questions) {
      final response = controller.responses[question.id];
      if (response == null) return false;

      if (question.type == 'Matrix') {
        final value = response['value'] as List;
        final subQuestions = question.meta.length;
        if (value.length < subQuestions) return false;
      }
    }
    return true;
  }
}
