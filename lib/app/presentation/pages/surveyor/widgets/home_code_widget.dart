import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

import '../../../../../core/values/app_colors.dart';
import '../../../widgets/primary_button.dart';

class HomeCodeController extends GetxController {
  final homeCode = "".obs;
  final isCodeGenerated = false.obs;

  void generateHomeCode() {
    final now = DateTime.now();

    final letters = String.fromCharCodes([
      65 + (now.millisecond % 26), // Letra 1
      65 + (now.second % 26),      // Letra 2
      65 + (now.minute % 26),      // Letra 3
      65 + (now.hour % 26),        // Letra 4
    ]);

    final random = Random(now.microsecond + now.millisecond + now.second + now.minute + now.hour);
    final numbers = List.generate(4, (_) => random.nextInt(10)).join();

    homeCode.value = "$letters-$numbers";
    isCodeGenerated.value = true;
  }


  void resetHomeCode() {
    homeCode.value = "";
    isCodeGenerated.value = false;
  }
}


// Widget para la interfaz de usuario
class HomeCodeWidget extends StatelessWidget {
  final Function(String homeCode) onCodeGenerated;

  const HomeCodeWidget({
    super.key,
    required this.onCodeGenerated,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeCodeController());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          const Text(
            'Código de hogar',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: controller.isCodeGenerated.value
                      ? AppColors.codeBackground
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.isCodeGenerated.value
                      ? controller.homeCode.value
                      : "---- ----",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )),
          const SizedBox(height: 10),
          Obx(
            () => controller.isCodeGenerated.value
                ? const SizedBox()
                : PrimaryButton(
                    onPressed: () {
                      controller.generateHomeCode();
                      onCodeGenerated(controller.homeCode.value);
                    },
                    isLoading: false,
                    child: 'Nuevo hogar',
                  ),
          ),
        ],
      ),
    );
  }
}
