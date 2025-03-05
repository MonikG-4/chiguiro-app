class ValidatorLoginFields {
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Por favor, ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Por favor, ingresa un correo válido';
    }

    return null;
  }

  static String? confirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Por favor, confirma tu contraseña';
    }
    if (confirmPassword != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Por favor, ingresa tu contraseña';
    }
    // final passwordRegex = RegExp(
    //     r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%]).{8,}$'
    // );
    // if (!passwordRegex.hasMatch(password)) {
    //   return 'Por favor, ingresa una contraseña válida';
    // }
    return null;
  }
}