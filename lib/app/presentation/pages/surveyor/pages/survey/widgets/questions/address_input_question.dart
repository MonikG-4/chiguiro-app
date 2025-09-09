import 'package:flutter/material.dart';

import '../../../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_input.dart';
import '../custom_select.dart';

class AddressInputQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const AddressInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<AddressInputQuestion> createState() => _AddressInputQuestionState();
}

class _AddressInputQuestionState extends State<AddressInputQuestion> {
  final _typeViaOptions = [
    'Calle (CL)',
    'Carrera (KR)',
    'Avenida (AV)',
    'Avenida Calle (AC)',
    'Avenida Carrera (AK)',
    'Diagonal (DG)',
    'Transversal (TV)',
    'Circular (CQ)',
    'Otra'
  ];

  final _typeViaController = TextEditingController();
  final _mainStreetController = TextEditingController();
  final _secondaryStreetController = TextEditingController();
  final _identifierController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  String get composedAddress {
    final type = _typeViaController.text;
    final main = _mainStreetController.text;
    final sec = _secondaryStreetController.text;
    final id = _identifierController.text;
    final comp = _complementController.text;
    final barrio = _neighborhoodController.text;

    String address = '';

    if (type.isNotEmpty) address += type;
    if (main.isNotEmpty) address += ' $main';
    if (sec.isNotEmpty) address += ' # $sec';
    if (id.isNotEmpty) address += '–$id';

    if (comp.isNotEmpty) address += ' $comp';
    if (barrio.isNotEmpty) address += ' ($barrio)';

    return address.trim().toUpperCase();
  }

  void _updateResponse() {
    final value = composedAddress;
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _typeViaController.addListener(_updateResponse);
    _mainStreetController.addListener(_updateResponse);
    _secondaryStreetController.addListener(_updateResponse);
    _identifierController.addListener(_updateResponse);
    _complementController.addListener(_updateResponse);
    _neighborhoodController.addListener(_updateResponse);

    _updateResponse();
  }

  @override
  void dispose() {
    _typeViaController.dispose();
    _mainStreetController.dispose();
    _secondaryStreetController.dispose();
    _identifierController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: (value) {
        final composed = composedAddress;
        final error =
            widget.controller.validatorMandatory(widget.question)(composed);
        return composed.isEmpty ? error : null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipo de vía',
                style: TextStyle(fontWeight: FontWeight.w600)),
            CustomSelect(
              value: _typeViaController.text.isEmpty
                  ? null
                  : _typeViaController.text,
              items: _typeViaOptions,
              label: 'Tipo de vía',
              keyDropdown: GlobalKey(debugLabel: widget.question.id),
              state: state,
              onSelected: (value) {
                _typeViaController.text = value!;
                _updateResponse();
              },
            ),
            const SizedBox(height: 8),
            const Text('N° de vía principal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            CustomInput(
              controller: _mainStreetController,
              inputType: InputValueType.text,
              hintText: 'N° de vía principal',
              errorText: state.errorText,
              onChanged: (value) => {
                _updateResponse(),
                state.validate(),
              },
            ),
            const SizedBox(height: 8),
            const Text('N° de vía secundaria (después del #)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            CustomInput(
              controller: _secondaryStreetController,
              inputType: InputValueType.text,
              hintText: 'N° de vía secundaria (después del #)',
              errorText: state.errorText,
              onChanged: (value) => {
                _updateResponse(),
                state.validate(),
              },            ),
            const SizedBox(height: 8),
            const Text('N° de identificación (después del -)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            CustomInput(
              controller: _identifierController,
              inputType: InputValueType.text,
              hintText: 'N° de identificación (después del -)',
              errorText: state.errorText,
              onChanged: (value) => {
                _updateResponse(),
                state.validate(),
              },            ),
            const SizedBox(height: 8),
            const Text('Complemento adicional',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            CustomInput(
              controller: _complementController,
              inputType: InputValueType.text,
              hintText: 'Complemento adicional',
              errorText: state.errorText,
              onChanged: (value) => {
                _updateResponse(),
                state.validate(),
              },            ),
            const SizedBox(height: 8),
            const Text('Barrio, centro poblado o vereda',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            CustomInput(
              controller: _neighborhoodController,
              inputType: InputValueType.text,
              hintText: 'Barrio, centro poblado o vereda',
              errorText: state.errorText,
              onChanged: (value) => {
                _updateResponse(),
                state.validate(),
              },            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColorScheme.primary.withOpacity(0.1),
                border: Border.all(color: AppColorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                composedAddress.isNotEmpty
                    ? 'Dirección: $composedAddress'
                    : 'Esperando respuesta ...',
                style: TextStyle(
                  fontWeight: composedAddress.isNotEmpty
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
