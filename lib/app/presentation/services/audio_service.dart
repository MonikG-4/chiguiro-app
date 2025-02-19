import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/message_handler.dart';
import '../../../core/utils/snackbar_message_model.dart';

class AudioService extends GetxService {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();

  final RxBool isRecording = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString recordingPath = ''.obs;
  final RxInt recordingDuration = 0.obs;
  Timer? _timer;
  final RxDouble amplitude = 0.0.obs;

  final Rx<SnackbarMessage> message = Rx<SnackbarMessage>(SnackbarMessage());

  @override
  Future<void> onInit() async {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
    await _initializeRecorder();

  }

  Future<void> _initializeRecorder() async {
    if (isInitialized.value) return;

    try {
      await _audioRecorder.openRecorder();
      isInitialized.value = true;
    } catch (e) {
      message.update((val) {
        val?.message = 'No se pudo inicializar el grabador';
        val?.state = 'error';
      });
    }
  }

  Future<bool> checkPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> requestAudioPermission() async {
    final permissionGranted = await checkPermission();

    if (!permissionGranted) {
      Get.dialog(
        AlertDialog(
          title: const Text('Permiso de ubicación'),
          content: const Text(
              'Esta aplicación necesita acceso a tu microfono para funcionar correctamente. '
                  '¿Deseas permitir el acceso?'
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Get.back();
                checkPermission();
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('No'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }


  Future<void> startRecording() async {
    if (!isInitialized.value) {
      await _initializeRecorder();
    }

    if (isRecording.value) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/audio_record.aac';

      await _audioRecorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,

      );

      recordingPath.value = path;
      isRecording.value = true;
      recordingDuration.value = 0;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        recordingDuration.value++;
      });

    } catch (e) {
      message.update((val) {
        val?.message = 'No se pudo iniciar la grabación';
        val?.state = 'error';
      });
    }
  }



  Future<String?> stopRecording() async {
    if (!isRecording.value) {
      return null;
    }

    try {
      final path = await _audioRecorder.stopRecorder();
      isRecording.value = false;

      _timer?.cancel();

      if (path != null) {
        final file = File(path);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        return base64String;
      }
    } catch (e) {
      message.update((val) {
        val?.message = 'No se pudo detener la grabación';
        val?.state = 'error';
      });
    }
    return null;
  }


  @override
  void onClose() async {
    await _audioRecorder.closeRecorder();
    super.onClose();
  }
}
