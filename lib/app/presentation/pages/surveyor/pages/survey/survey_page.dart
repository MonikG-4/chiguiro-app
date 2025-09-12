import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import '../../../../../../core/theme/app_colors_theme.dart';
import '../../../../widgets/confirmation_dialog.dart';
import '../../../../widgets/connectivity_banner.dart';
import '../../../../widgets/primary_button.dart';
import 'widgets/audio_location_panel.dart';
import 'widgets/custom_progress_bar.dart';
import 'widgets/keep_alive_survey_question.dart';
import 'widgets/question_widget_factory.dart';
import '../../../../../presentation/controllers/survey_controller.dart';

class SurveyPage extends GetView<SurveyController> {
  final _formKey = GlobalKey<FormState>();

  SurveyPage({super.key});

  @override
  Widget build(BuildContext context) {
    _setupPopHandler(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final confirmed = await _showExitConfirmationDialog(context);
            if (confirmed) {
              Get.back();
            }
          },
        ),
        title: Obx(() => Text(controller.survey.value?.name ?? 'Encuesta')),
      ),
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
              if (controller.isVoiceRecorder.value || controller.isGeoLocation.value)
                AudioLocationPanel(
                  showLocation: controller.survey.value?.geoLocation ?? false,
                  showAudioRecorder: controller.survey.value?.voiceRecorder ?? false,
                ),
              _buildQuestionsForm(context),
              _buildProgressBar(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: PrimaryButton(
              onPressed: controller.isLoadingSendSurvey.value
                  ? null
                  : () => _submitSurvey(),
              isLoading: controller.isLoadingSendSurvey.value,
              text: 'Enviar Encuesta',
            ),
        );
      }),

    );
  }

  void _setupPopHandler(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      route?.addScopedWillPopCallback(() async {
        if (controller.allowPop.value) return true;
        final confirmed = await _showExitConfirmationDialog(context);
        if (confirmed) {
          controller.allowPop.value = true;
          Get.back();
        }
        return false;
      });
    });
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final confirmed = await Get.dialog<bool>(
      const ConfirmationDialog(
        message: 'Si regresa perderá todo el progreso. ¿Desea continuar?',
      ),
    );
    return confirmed == true;
  }

  Widget _buildQuestionsForm(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Padding(
      padding: EdgeInsets.only(
        top: (controller.isVoiceRecorder.value || controller.isGeoLocation.value) ? 80.0 : 40.0,
        left: 16.0,
        right: 16.0,
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
                    color: scheme.sectionBackground.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: scheme.sectionBackground,
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: parseSimpleHtml(section.name, scheme: scheme),
                      ),
                      const SizedBox(height: 8.0),
                      if (section.description != null)
                        RichText(
                          textAlign: TextAlign.center,
                          text: parseSimpleHtml(section.description!, scheme: scheme),
                        ),

                    ],
                  ),
                ),
                ...visibleQuestions.map((question) {
                  return KeepAliveSurveyQuestion(
                    key: ValueKey('question-${question.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: QuestionWidgetFactory.createQuestionWidget(question),
                    ),
                  );
                }),
              ],
            );
          }).toList();

          return SingleChildScrollView(
            child: Column(children: visibleSections),
          );
        }),
      ),
    );
  }

  TextSpan parseSimpleHtml(String html, {required AppColorScheme scheme, TextStyle? baseStyle}) {
    final document = html_parser.parse(html);
    final body = document.body;

    return _parseNode(
      body!,
      baseStyle ?? TextStyle(fontSize: 16, color: scheme.onFirstBackground),
    );
  }

  TextSpan _parseNode(dom.Node node, TextStyle currentStyle) {
    if (node is dom.Text) {
      return TextSpan(text: node.text, style: currentStyle);
    }

    if (node is dom.Element) {
      TextStyle updatedStyle = currentStyle;

      switch (node.localName) {
        case 'b':
          updatedStyle = updatedStyle.merge(const TextStyle(fontWeight: FontWeight.bold));
          break;
        case 'i':
          updatedStyle = updatedStyle.merge(const TextStyle(fontStyle: FontStyle.italic));
          break;
        case 'u':
          updatedStyle = updatedStyle.merge(const TextStyle(decoration: TextDecoration.underline));
          break;
        case 'p':
          break;
      }

      return TextSpan(
        style: updatedStyle,
        children: node.nodes.map((child) => _parseNode(child, updatedStyle)).toList(),
      );
    }

    return const TextSpan(text: '');
  }

  Widget _buildProgressBar() {
    return Positioned(
      top: (controller.isVoiceRecorder.value || controller.isGeoLocation.value) ? 50 : 0,
      left: 0,
      right: 0,
      child: Obx(() {
        final totalQuestions = controller.sections.fold(
          0,
              (sum, section) => sum + section.surveyQuestion.length,
        ) - controller.hiddenQuestions.length;
        final answeredQuestions = controller.responses.length;
        final progress = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      }),
    );
  }

  Future<void> _submitSurvey() async {
    if (_formKey.currentState!.validate() & controller.validateAllQuestions()) {
      controller.saveLocalSurvey(controller.idSurveyor.value);
    }
  }
}
