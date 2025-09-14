import 'package:chiguiro_front_app/app/presentation/widgets/custom_text_button_redirect.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/bottom_pages.dart';
import '../../widgets/custom_view_form.dart';
import '../../widgets/primary_button.dart';
import 'widgets/forgot_password_form.dart';

class ForgotPasswordPage extends GetView<AuthController> {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomViewForm(
        formKey: formKey,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                '¿Olvidaste la contraseña?',
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
            'Ingresa tu direccion de correo electronico y te mostraremos los siguientes pasos para restablecer tu contraseña',
        form: ForgotPasswordForm(
          emailController: emailController,
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
                const SizedBox(height: 64),
                PrimaryButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            controller.forgotPassword(emailController.text);
                          }
                        },
                  isLoading: controller.isLoading.value,
                  text: 'Enviar correo',
                ),
              ],
            )),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  void _handleBackNavigation() {
    Get.closeAllSnackbars();
    Get.offAllNamed(Routes.LOGIN);
  }
}
