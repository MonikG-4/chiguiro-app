import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/services/cache_storage_service.dart';
import '../../../../../../core/values/app_colors.dart';
import '../../../../../domain/entities/auth_response.dart';
import '../../../../../presentation/controllers/survey_controller.dart';
import '../../../../widgets/connectivity_banner.dart';
import '../../../../widgets/primary_button.dart';
import 'widgets/audio_location_panel.dart';
import 'widgets/custom_progress_bar.dart';
import 'widgets/keep_alive_survey_question.dart';
import 'widgets/question_widget_factory.dart';

class SurveyPage extends GetView<SurveyController> {
  final AuthResponse authResponse;
  final _formKey = GlobalKey<FormState>();

  SurveyPage({super.key})
      : authResponse = Get.find<CacheStorageService>().authResponse!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.survey.value!.name),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoadingQuestion.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.sections.isEmpty) {
          return const Center(child: Text('No hay secciones disponibles'));
        }

        return Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Stack(
            children: [

              if (controller.isVoiceRecorder.value ||
                  controller.isGeoLocation.value)
                AudioLocationPanel(
                  showLocation: controller.survey.value!.geoLocation,
                  showAudioRecorder: controller.survey.value!.voiceRecorder,
                ),

              _buildQuestionsForm(context),
              _buildProgressBar(),

              _buildSubmitButton(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuestionsForm(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top:
            (controller.isVoiceRecorder.value || controller.isGeoLocation.value)
                ? 80.0
                : 40.0,
        left: 16.0,
        right: 16.0,
        bottom: 100.0,
      ),
      child: Form(
        key: _formKey,
        child: Obx(() {
          final visibleSections = controller.sections.map((section) {
            final visibleQuestions = section.surveyQuestion
                .where((q) => !controller.hiddenQuestions.contains(q.id))
                .toList();

            if (visibleQuestions.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              key: ValueKey('section-${section.id}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.section,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        section.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      if (section.description != null)
                        Text(
                          section.description!,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        )
                    ],
                  ),
                ),
                ...visibleQuestions.map((question) {
                  return KeepAliveSurveyQuestion(
                    key: ValueKey('question-${question.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child:
                          QuestionWidgetFactory.createQuestionWidget(question),
                    ),
                  );
                }),
              ],
            );
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: visibleSections,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Positioned(
      top: (controller.isVoiceRecorder.value || controller.isGeoLocation.value)
          ? 50
          : 0,
      left: 0,
      right: 0,
      child: Obx(
        () {
          final totalQuestions = controller.sections.fold(
                0,
                (sum, section) => sum + section.surveyQuestion.length,
              ) -
              controller.hiddenQuestions.length;
          final answeredQuestions = controller.responses.length;
          final progress =
              totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0),
                CustomProgressBar(progress: progress),
                const SizedBox(height: 8.0),
                ConnectivityBanner(),

              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _fillSurveyWithRandomResponses() async {
    for (var section in controller.sections) {
      for (var question in section.surveyQuestion) {
        if (!controller.hiddenQuestions.contains(question.id)) {
          switch (question.type) {
            case 'Boolean':
            case 'Radio':
            case 'Select':
              final option =
                  question.meta[Random().nextInt(question.meta.length)];
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': option,
              };
              break;

            case 'String':
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': 'Respuesta automática',
              };
              break;

            case 'Integer':
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': Random().nextInt(100),
              };
              break;

            case 'Double':
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': (Random().nextDouble() * 100),
              };
              break;

            case 'Star':
            case 'Scale':
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': Random().nextInt(5) + 1,
              };
              break;

            case 'Check':
              final randomSelections = question.meta
                  .where((_) => Random().nextBool())
                  .toList()
                  .where((element) => element.length > 1)
                  .toList();
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': randomSelections,
              };
              break;

            case 'Location':
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': ['Colombia', '50 - Meta', '50001 - Villavicencio'],
              };
              break;

            case 'Date':
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': DateTime.now(),
              };
              break;

            case 'Matrix':
              final matrixResults = question.meta.map((meta) {
                return {
                  meta: question
                      .meta2?[Random().nextInt(question.meta2!.length)]
                      .toString()
                };
              }).toList();

              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': matrixResults,
              };
              break;

            case 'MatrixTime':
              final matrixTimeResults = <Map<String, String>>[];
              if (question.meta2 != null) {
                for (final row in question.meta) {
                  for (final column in question.meta2!) {
                    matrixTimeResults.add({
                      'fila': row,
                      'columna': column,
                      'respuesta': Random().nextInt(24).toString(),
                    });
                  }
                }
              }
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': matrixTimeResults,
              };
              break;

            case 'MatrixDouble':
              final matrixDoubleResults = <Map<String, String>>[];
              if (question.meta2 != null) {
                for (final row in question.meta) {
                  for (final column in question.meta2!) {
                    matrixDoubleResults.add({
                      'fila': row,
                      'columna': column,
                      'respuesta': Random().nextDouble().toString(),
                    });
                  }
                }
              }
              controller.responses[question.id] = {
                'question': question.question,
                'type': question.type,
                'value': matrixDoubleResults,
              };
              break;

            default:
              break;
          }
        }
      }
    }
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PrimaryButton(
              onPressed: controller.isLoadingSendSurvey.value
                  ? null
                  : () => _submitSurvey(),
              isLoading: controller.isLoadingSendSurvey.value,
              child: 'Enviar Encuesta',
            ),
            // const SizedBox(height: 8),
            // PrimaryButton(
            //   isLoading: false,
            //   onPressed: () async {
            //     await _fillSurveyWithRandomResponses();
            //   },
            //   child: 'Responder Aleatoriamente',
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSurvey() async {
    if (_formKey.currentState!.validate() & controller.validateAllQuestions()) {
      controller.saveLocalSurvey(authResponse.id);
    }
  }
}
