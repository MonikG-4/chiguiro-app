import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_surveyor_controller.dart';
import '../../widgets/bottom_pages.dart';
import '../../widgets/custom_text_button_redirect.dart';
import '../../widgets/custom_view_form.dart';
import '../../widgets/primary_button.dart';
import 'widgets/change_password_form.dart';

class ChangePasswordPage extends GetView<DashboardSurveyorController> {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: CustomViewForm(
        formKey: formKey,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              SizedBox(height: 36),
              Text(
                'Nueva contraseña',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        subtitle:
        'Para tu seguridad, la contraseña debe cumplir los siguientes requisitos:'
            '\n   • Mínimo 8 caracteres'
            '\n   • Al menos una letra mayúscula (A-Z)'
            '\n   • Al menos una letra minúscula (a-z)'
            '\n   • Al menos un número (0-9)'
            '\n   • Un carácter especial(!,@,#,\$,%)',


        form: ChangePasswordForm(
          passwordController: passwordController,
        ),
        buttonText: Column(
          children: [
            const SizedBox(height: 16),
            CustomTextButtonRedirect(
              onPressed: _handleBackNavigation,
              label: 'Volver al inicio',
            ),
          ],
        ),
        textButton: Obx(() => Column(
          children: [
            const SizedBox(height: 40),
            PrimaryButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                if (formKey.currentState!.validate()) {
                  controller.changePassword(passwordController.text);
                }
              },
              isLoading: controller.isLoading.value,
              child: 'Actualizar contraseña',
            ),
          ],
        )),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  void _handleBackNavigation() {
    Get.closeAllSnackbars();
    Get.back();
  }
}
