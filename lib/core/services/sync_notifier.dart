import 'package:get/get.dart';

class SyncNotifier extends GetxService {
  final RxBool isSyncComplete = false.obs;

  void notifySyncComplete() {
    print('Notificando sync completo');
    isSyncComplete.value = true;
  }

  void resetSyncStatus() {
    print('Reseteando sync status');
    isSyncComplete.value = false;
  }
}
