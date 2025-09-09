import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../../../../../../core/theme/app_colors_theme.dart';
import '../../../../../../../domain/entities/survey_question.dart';
import '../../../../../../controllers/survey_controller.dart';

class SignatureInputQuestion extends StatefulWidget {
  final SurveyQuestion question;
  final SurveyController controller;

  const SignatureInputQuestion({
    super.key,
    required this.question,
    required this.controller,
  });

  @override
  State<SignatureInputQuestion> createState() => _SignatureInputQuestionState();
}

class _SignatureInputQuestionState extends State<SignatureInputQuestion> {
  final RxBool isLocked = false.obs;

  SignatureController? _controller;
  Brightness? _lastBrightness;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureControllerForTheme();
  }

  void _ensureControllerForTheme() {
    final brightness = Theme.of(context).brightness;

    if (_controller == null || _lastBrightness != brightness) {
      final oldPoints = _controller?.points; // conserva lo dibujado
      _controller?.dispose();

      _controller = SignatureController(
        points: oldPoints,
        penStrokeWidth: 3,
        penColor: brightness == Brightness.dark ? Colors.white : Colors.black,
      )..onDrawEnd = () async {
        if (!_controller!.isEmpty && !isLocked.value) {
          await widget.controller.saveSignature(widget.question, _controller!);
          isLocked.value = true;
        }
      };

      _lastBrightness = brightness;
      setState(() {}); // repintar con el nuevo controller
    }
  }

  void _clearSignature() {
    _controller?.clear();
    isLocked.value = false;
    widget.controller.responses.remove(widget.question.id);
    widget.controller.responses.refresh();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return Obx(() {
      final hasSignature =
      widget.controller.responses.containsKey(widget.question.id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: hasSignature ? scheme.iconBackground : scheme.border,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: scheme.secondBackground,
                ),
                child: AbsorbPointer(
                  absorbing: isLocked.value,
                  child: Signature(
                    controller: _controller!,
                    backgroundColor: scheme.secondBackground,
                  ),
                ),
              ),
              if (isLocked.value)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: _clearSignature,
                    icon: const Icon(Icons.clear, size: 20),
                    color: Colors.grey[600],
                    tooltip: 'Limpiar firma',
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}
