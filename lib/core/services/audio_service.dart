import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/message_handler.dart';
import '../utils/snackbar_message_model.dart';

class AudioService extends GetxService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  final isRecording = false.obs;
  final isInitialized = false.obs;
  final recordingPath = ''.obs;
  final recordingDuration = 0.obs;
  final amplitude = 0.0.obs;
  final message = Rx<SnackbarMessage>(SnackbarMessage());

  Timer? _timer;

  @override
  Future<void> onInit() async {
    super.onInit();
    MessageHandler.setupSnackbarListener(message);
  }

  Future<bool> requestPermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) status = await Permission.microphone.request();

    if (status.isPermanentlyDenied) {
      await _showSettingsDialog('micrófono');
      return false;
    }
    return status.isGranted || status.isLimited;
  }

  Future<void> initialize() async {
    if (isInitialized.value) return;
    if (!await requestPermission()) return;

    try {
      await _recorder.openRecorder();
      isInitialized.value = true;
    } catch (_) {
      _showError('No se pudo inicializar el grabador');
    }
  }

  Future<void> startRecording() async {
    if (isRecording.value) return;
    await initialize();
    if (!isInitialized.value) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/audio_record.aac';

      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      recordingPath.value = path;
      isRecording.value = true;
      recordingDuration.value = 0;

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        recordingDuration.value++;
      });
    } catch (_) {
      _showError('No se pudo iniciar la grabación');
    }
  }

  Future<String?> stopRecording() async {
    if (!isRecording.value) return null;

    try {
      final path = await _recorder.stopRecorder();
      isRecording.value = false;
      _timer?.cancel();

      if (path != null) {
        final file = File(path);
        return base64Encode(await file.readAsBytes());
      }
    } catch (_) {
      _showError('No se pudo detener la grabación');
    }
    return null;
  }

  Future<void> _showSettingsDialog(String type) async {
    await Get.dialog(
      AlertDialog(
        title: Text('Permiso de $type requerido'),
        content: Text(
          'Debes habilitar el acceso a tu $type desde la configuración para continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showError(String msg) {
    message.update((val) {
      val?.title = 'Servicio de audio';
      val?.message = msg;
      val?.state = 'error';
    });
  }

  @override
  Future<void> onClose() async {
    _timer?.cancel();
    if (_recorder.isStopped) {
      await _recorder.closeRecorder();
    } else {
      try {
        await _recorder.stopRecorder();
        await _recorder.closeRecorder();
      } catch (_) {}
    }
    super.onClose();
  }
}
