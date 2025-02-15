import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/values/location.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_select.dart';

class LocationInputQuestion extends StatelessWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const LocationInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey countryKey =
        GlobalKey(debugLabel: '${question.id}_country');
    final GlobalKey departmentKey =
        GlobalKey(debugLabel: '${question.id}_department');
    final GlobalKey municipalityKey =
        GlobalKey(debugLabel: '${question.id}_municipality');

    final countries = LocationData.getLocationData()['countries'] as List;

    return FormField<List<String>>(
      validator: controller.validatorMandatory(question),
      builder: (FormFieldState<List<String>> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              final countryValue = getLocationValue(question.id, 0);
              return CustomSelect(
                keyDropdown: countryKey,
                value: countryValue,
                items: countries.map((c) => c['name'] as String).toList(),
                label: 'País',
                state: state,
                onSelected: (value) {
                  if (value == null) {
                    controller.responses.remove(question.id);
                  } else {
                    final selectedCountry =
                        countries.firstWhere((c) => c['name'] == value);
                    controller.responses[question.id] = {
                      'question': question.question,
                      'type': question.type,
                      'value': [value],
                      'departments': selectedCountry['departments'],
                    };
                  }
                  state.didChange(controller.responses[question.id]?['value']);
                  state.validate();
                },
              );
            }),
            const SizedBox(height: 8),
            Obx(() {
              final selectedCountry = getLocationValue(question.id, 0);
              if (selectedCountry == null) return const SizedBox.shrink();

              final departments =
                  (controller.responses[question.id]?['departments'] as List)
                      .map((d) => d['departamento'] as String)
                      .toList();

              return CustomSelect(
                keyDropdown: departmentKey,
                value: getLocationValue(question.id, 1),
                items: departments,
                label: 'Departamento',
                state: state,
                onSelected: (value) {
                  if (value == null) {
                    _clearAfterIndex(question.id, 1);
                  } else {
                    final selectedDepartment = (controller
                            .responses[question.id]?['departments'] as List)
                        .firstWhere((d) => d['departamento'] == value);
                    final currentValue = getLocationValueList(question.id);
                    currentValue.length < 2
                        ? currentValue.add(value)
                        : currentValue[1] = value;
                    controller.responses[question.id]?['municipalities'] =
                        selectedDepartment['ciudades'];
                  }
                  state.didChange(controller.responses[question.id]?['value']);
                  state.validate();
                },
              );
            }),
            const SizedBox(height: 8),
            Obx(() {
              final selectedDepartment = getLocationValue(question.id, 1);
              if (selectedDepartment == null) return const SizedBox.shrink();

              final municipalities =
                  (controller.responses[question.id]?['municipalities'] as List)
                      .cast<String>();

              return CustomSelect(
                keyDropdown: municipalityKey,
                value: getLocationValue(question.id, 2),
                items: municipalities,
                label: 'Municipio',
                state: state,
                onSelected: (value) {
                  if (value != null) {
                    final currentValue = getLocationValueList(question.id);
                    currentValue.length < 3
                        ? currentValue.add(value)
                        : currentValue[2] = value;
                  }
                  state.didChange(controller.responses[question.id]?['value']);
                  state.validate();
                },
              );
            }),
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

  String? getLocationValue(String questionId, int index) =>
      getLocationValueList(questionId).length > index
          ? getLocationValueList(questionId)[index]
          : null;
  List<String> getLocationValueList(String questionId) =>
      controller.responses[questionId]?['value'] as List<String>? ?? [];

  void _clearAfterIndex(String questionId, int index) =>
      controller.responses[questionId]?['value'] =
          getLocationValueList(questionId).sublist(0, index);
}
