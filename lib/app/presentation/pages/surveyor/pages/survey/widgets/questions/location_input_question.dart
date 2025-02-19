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
              final selectedValues = getLocationValueList(question.id);
              final countryValue = selectedValues.isNotEmpty ? selectedValues[0] : null;

              return CustomSelect(
                keyDropdown: countryKey,
                value: countryValue,
                items: countries.map((c) => c['name'] as String).toList(),
                label: 'País',
                state: state,
                onSelected: (value) {
                  if (value == null) {
                    _clearAfterIndex(question.id, 0);
                  } else {
                    _setLocationValueAt(question.id, 0, value);
                    _clearAfterIndex(question.id, 1);
                  }
                  _updateResponses(question, state);
                },
              );
            }),
            const SizedBox(height: 8),
            Obx(() {
              final selectedValues = getLocationValueList(question.id);
              if (selectedValues.isEmpty) return const SizedBox.shrink();

              final selectedCountry = selectedValues[0];
              final countryData =
              countries.firstWhereOrNull((c) => c['name'] == selectedCountry);

              if (countryData == null) return const SizedBox.shrink();

              final departments = (countryData['departments'] as List)
                  .map((d) => d['departamento'] as String)
                  .toList();

              final departmentValue =
              selectedValues.length > 1 ? selectedValues[1] : null;

              return CustomSelect(
                keyDropdown: departmentKey,
                value: departmentValue,
                items: departments,
                label: 'Departamento',
                state: state,
                onSelected: (value) {
                  if (value == null) {
                    _clearAfterIndex(question.id, 1);
                  } else {
                    _setLocationValueAt(question.id, 1, value);
                    _clearAfterIndex(question.id, 2);
                  }
                  _updateResponses(question, state);
                },
              );
            }),
            const SizedBox(height: 8),
            Obx(() {
              final selectedValues = getLocationValueList(question.id);
              if (selectedValues.length < 2) return const SizedBox.shrink();

              final selectedCountry = selectedValues[0];
              final selectedDepartment = selectedValues[1];

              final countryData =
              countries.firstWhereOrNull((c) => c['name'] == selectedCountry);

              final departmentData = (countryData?['departments'] as List?)
                  ?.firstWhereOrNull(
                      (d) => d['departamento'] == selectedDepartment);

              if (departmentData == null) return const SizedBox.shrink();

              final municipalities =
              (departmentData['ciudades'] as List).cast<String>();

              final municipalityValue =
              selectedValues.length > 2 ? selectedValues[2] : null;

              return CustomSelect(
                keyDropdown: municipalityKey,
                value: municipalityValue,
                items: municipalities,
                label: 'Municipio',
                state: state,
                onSelected: (value) {
                  if (value == null) {
                    _clearAfterIndex(question.id, 2);
                  } else {
                    _setLocationValueAt(question.id, 2, value);
                  }
                  _updateResponses(question, state);
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
      (controller.responses[questionId]?['value'] as List<String>?) ?? [];

  void _setLocationValueAt(String questionId, int index, String value) {
    final currentValues = getLocationValueList(questionId);

    // Ajustar el tamaño de la lista si es necesario
    while (currentValues.length <= index) {
      currentValues.add('');
    }

    currentValues[index] = value;

    controller.responses[questionId] = {
      'question': question.question,
      'type': question.type,
      'value': currentValues,
    };
  }


  void _clearAfterIndex(String questionId, int index) {
    final currentValues = getLocationValueList(questionId);
    if (currentValues.length > index + 1) {
      controller.responses[questionId]?['value'] = currentValues.sublist(0, index + 1);
    }
  }


  void _updateResponses(SurveyQuestion question, FormFieldState<List<String>> state) {
    final values = getLocationValueList(question.id);
    if (values.isEmpty) {
      controller.responses.remove(question.id);
    } else {
      controller.responses[question.id] = {
        'question': question.question,
        'type': question.type,
        'value': values,
      };
    }
    state.didChange(values);
    state.validate();
  }
}
