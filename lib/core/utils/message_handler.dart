import 'package:get/get.dart';

import '../../app/presentation/widgets/alerts_message.dart';
import 'snackbar_message_model.dart';

class MessageHandler {
  static void setupSnackbarListener(Rx<SnackbarMessage> snackbarMessage) {

    ever(snackbarMessage, (SnackbarMessage msg) {
      if (msg.isNotEmpty) {
        AlertMessage.showSnackbar(
          title: msg.title,
          message: msg.message,
          state: msg.state,
        );
        snackbarMessage.value = SnackbarMessage();
      }
    });
  }
}
