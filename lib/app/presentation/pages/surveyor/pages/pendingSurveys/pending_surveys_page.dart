import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../../../core/values/app_colors.dart';
import '../../../../../data/models/survey_entry_model.dart';
import '../../../../controllers/survey_controller.dart';

class PendingSurveysPage extends GetView<SurveyController> {
  final int? _surveyorId;

  PendingSurveysPage({super.key}) : _surveyorId = Get.arguments['surveyorId'];

  @override
  Widget build(BuildContext context) {
    if (_surveyorId == null) {
      return const Scaffold(
        body: Center(child: Text('ID del encuestador no disponible')),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSurveys(_surveyorId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuestas pendientes'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await controller.fetchSurveys(_surveyorId);
            },
            child: Obx(() => controller.surveyPending.isEmpty
                ? const Center(child: Text('No hay encuestas pendientes'))
                : ListView.builder(
              itemCount: controller.surveyPending.length,
              itemBuilder: (context, index) {
                final survey = controller.surveyPending[index];
                final surveyName = survey['surveyName'] ?? 'Encuesta sin nombre';
                final payload = survey['payload'] as SurveyEntryModel;
                final formattedDate = DateFormat('dd-MM-yyyy HH:mm')
                    .format(DateTime.parse(payload.finishedOn));

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    title: Text(surveyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(formattedDate),
                    trailing: IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () async {
                        controller.saveSurveyResults(survey);
                        // final response = await saveSurveyResults(survey['payload'].toJson());
                        // print('response: ${response.values}');
                      },
                    ),
                  ),
                );
              },
            )),
          ),
          Obx(() => controller.isLoadingSendSurvey.value
              ? Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> saveSurveyResults(Map<String, dynamic> entryInput) async {
    try {
      final response = await http.post(
        Uri.parse("https://chiguiro.proyen.co:7701/pond"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "query": """
              mutation entry( \$input: EntryInput!) {
                entry(input: \$input) {
                  id
                }
              }
          """,
          "variables": {
            "input": entryInput,
          },
        }),
      ).timeout(const Duration(seconds: 30)); // 🔥 Ajusta el timeout

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error en la petición: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error en la conexión: $e");
    }
  }
}
