import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/services/cache_storage_service.dart';
import '../../../../../../../../core/values/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<CacheStorageService>().authResponse!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Información Personal"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF27C3B1),
              child: Icon(Icons.person, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            _buildTextField(label: 'Nombre', initialValue: user.name),
            const SizedBox(height: 12),
            _buildTextField(label: 'Apellido', initialValue: user.surname),
            const SizedBox(height: 12),
            _buildTextField(
                label: 'Correo', initialValue: user.email),
            const SizedBox(height: 12),
            _buildPhoneField(user.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label, required String initialValue}) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: _border(),
        focusedBorder: _border(),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildPhoneField(String initialValue) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Número Telefónico',
        filled: true,
        fillColor: Colors.white,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefix: Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Color(0xFFE3EAF3),
                width: 1.5,
              ),
            ),
          ),
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/co.png',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 6),
              const Text(
                '+57',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
        ),
        enabledBorder: _border(),
        focusedBorder: _border(),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      );
}
