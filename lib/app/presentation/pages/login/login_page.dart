import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/values/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/bottom_pages.dart';
import '../../widgets/custom_text_button_redirect.dart';
import '../../widgets/custom_view_form.dart';
import '../../widgets/primary_button.dart';
import 'widgets/login_form.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
              'Ingresar',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        ),
        form: LoginForm(
          emailController: emailController,
          passwordController: passwordController,
        ),
        buttonText: Obx(
          () => Column(
            children: [
              const SizedBox(height: 28),
              PrimaryButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          controller.login(
                            emailController.text,
                            passwordController.text,
                          );
                        }
                      },
                isLoading: controller.isLoading.value,
                text: 'Ingresar',
              ),
            ],
          ),
        ),
        textButton: Column(
          children: [
            const SizedBox(height: 12),
            CustomTextButtonRedirect(
              onPressed: () {
                Get.toNamed(Routes.FORGOT_PASSWORD);
              },
              label: '¿Olvidaste la contraseña?',
              alignment: Alignment.centerRight,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
