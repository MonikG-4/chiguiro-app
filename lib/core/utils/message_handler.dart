import 'package:get/get.dart';
import '../../app/presentation/widgets/alerts_message.dart';
import 'snackbar_message_model.dart';

class MessageHandler {
  static String? _lastMessage;
  static DateTime? _lastMessageTime;

  static void setupSnackbarListener(Rx<SnackbarMessage> snackbarMessage) {
    ever(snackbarMessage, (SnackbarMessage msg) {
      final now = DateTime.now();

      if (msg.isEmpty) return;

      if (msg.message == _lastMessage &&
          _lastMessageTime != null &&
          now.difference(_lastMessageTime!).inSeconds < 1) {
        return;
      }

      _lastMessage = msg.message;
      _lastMessageTime = now;

      AlertMessage.showSnackbar(
        title: msg.title,
        message: msg.message,
        state: msg.state,
      );

      snackbarMessage.value = SnackbarMessage();
    });
  }
}
