import 'package:flutter/material.dart';

import '../../../../../../../../core/values/app_colors.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';
import '../custom_input.dart';
import '../custom_select.dart';

class BlockCodeInputQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const BlockCodeInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<BlockCodeInputQuestion> createState() => _BlockCodeInputQuestionState();
}

class _BlockCodeInputQuestionState extends State<BlockCodeInputQuestion> {
  final _blockCodeController = TextEditingController();
  final _regionController = TextEditingController();
  final _zoneController = TextEditingController();
  final _areaController = TextEditingController();

  final List<String> _regionOptions = [
    'Amazonía y Orinoquía',
    'Atlántica',
    'Central',
    'Oriental',
    'Pacífica',
    'Bogotá D.C.',
  ];

  final List<String> _zoneOptions = [
    'Rural',
    'Urbano',
  ];

  final List<String> _areaOptions = [
    'Cabecera municipal',
    'Centro poblado',
    'Rural disperso',
  ];

  void _updateResponse() {
    final List<String> values = [
      _blockCodeController.text.trim(),
      _regionController.text.trim(),
      _zoneController.text.trim(),
      _areaController.text.trim(),
    ];

    final isEmpty = values.every((element) => element.isEmpty);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEmpty) {
        widget.controller.responses.remove(widget.question.id);
      } else {
        widget.controller.responses[widget.question.id] = {
          'question': widget.question.question,
          'type': widget.question.type,
          'value': values,
        };
      }
      widget.controller.responses.refresh();

      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _blockCodeController.addListener(_updateResponse);
    _regionController.addListener(_updateResponse);
    _zoneController.addListener(_updateResponse);
    _areaController.addListener(_updateResponse);
  }

  @override
  void dispose() {
    _blockCodeController.dispose();
    _regionController.dispose();
    _zoneController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: (value) {
        final error = widget.controller
            .validatorMandatory(widget.question)(_blockCodeController.text);
        return _blockCodeController.text.trim().isEmpty ? error : null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final blockCode =
                          await widget.controller.fetchBlockCode();

                      if (blockCode != null) {
                        _blockCodeController.text = blockCode.blockCode;
                        _regionController.text = blockCode.region;
                        _zoneController.text = blockCode.zone;
                        _areaController.text = blockCode.area;

                        _updateResponse();
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.location_on_outlined),
                    label: const Text('Ubicar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successBorder.withOpacity(0.1),
                      foregroundColor: AppColors.successText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.successBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      widget.controller.redirectToMap();
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Ver mapa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.infoBorder.withOpacity(0.1),
                      foregroundColor: AppColors.infoText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.infoBorder),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Código de manzana',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            CustomInput(
              controller: _blockCodeController,
              inputType: InputValueType.text,
              hintText: 'Ingrese el código de manzana',
              errorText: state.errorText,
              onChanged: (_) => state.validate(),
            ),
            const SizedBox(height: 16),
            const Text('Región',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            CustomSelect(
              value: _regionController.text.isEmpty
                  ? null
                  : _regionController.text,
              items: _regionOptions,
              label: 'Región',
              keyDropdown:
                  GlobalKey(debugLabel: '${widget.question.id}_region'),
              state: state,
              onSelected: (value) {
                _regionController.text = value!;
                _updateResponse();
              },
            ),
            const SizedBox(height: 16),
            const Text('Zona',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            CustomSelect(
              value: _zoneController.text.isEmpty ? null : _zoneController.text,
              items: _zoneOptions,
              label: 'Zona',
              keyDropdown: GlobalKey(debugLabel: '${widget.question.id}_zone'),
              state: state,
              onSelected: (value) {
                _zoneController.text = value!;
                _updateResponse();
              },
            ),
            const SizedBox(height: 16),
            const Text('Area',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            CustomSelect(
              value: _areaController.text.isEmpty ? null : _areaController.text,
              items: _areaOptions,
              label: 'Area',
              keyDropdown: GlobalKey(debugLabel: '${widget.question.id}_zone'),
              state: state,
              onSelected: (value) {
                _areaController.text = value!;
                _updateResponse();
              },
            ),
          ],
        );
      },
    );
  }
}
