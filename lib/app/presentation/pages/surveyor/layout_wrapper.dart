 import 'package:chiguiro_front_app/app/presentation/pages/surveyor/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/cache_storage_service.dart';
import '../../../../core/values/app_colors.dart';
import '../../../bindings/home_binding.dart';
import '../../../bindings/revisit_binding.dart';
import '../../../bindings/settings_binding.dart';
import '../../../bindings/survey_pending_binding.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/pending_survey_controller.dart';
import '../../controllers/revisits_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../widgets/confirmation_dialog.dart';
import 'pages/home/home_page.dart';
import 'pages/home/widgets/download_splash.dart';
import 'pages/pendingSurveys/pending_surveys_page.dart';
import 'pages/revisits/revisit_page.dart';
import 'widgets/profile_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final RxInt selectedIndex = 0.obs;
  int lastIndex = 0;
  final loadedIndices = <int>{};

  // List of bindings a mano si quieres ejecutarlos antes
  final pages = <int, Widget>{
    0: const HomePage(),
    1: const RevisitsPage(),
    // 2: const SettingsPage(),
    2: const PendingSurveysPage(),
    3: const SettingsPage(),
  };


  final navItems = [
    {'icon': Icons.home_outlined, 'label': 'Inicio'},
    {'icon': Icons.watch_later_outlined, 'label': 'Revisitas'},
    // {'icon': Icons.stacked_bar_chart_outlined, 'label': 'Estadísticas'},
    {'icon': Icons.cloud_upload_outlined, 'label': 'En cola'},
    {'icon': Icons.settings_outlined, 'label': 'Ajustes'},
  ];

  final bindings = <int, Bindings>{
    0: HomeBinding(),
    1: RevisitsBinding(),
    // 2: SettingsBinding(),
    2: SurveyPendingBinding(),
    3: SettingsBinding(),
  };

  @override
  void initState() {
    super.initState();
    bindings[0]?.dependencies();
    loadedIndices.add(0);
  }

  Future<bool> _onWillPop() async {
    final confirmed = await Get.dialog<bool>(
      const ConfirmationDialog(
        message:
        '¿Estás seguro de que deseas salir de la aplicación?',
        confirmText: 'Salir',
      ),
    );

    return confirmed ?? false; // Solo sale si es true
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final user = Get.find<CacheStorageService>().authResponse!;
    final controller = Get.find<HomeController>();

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: _buildAppBar(user, isIOS),
          ),
          body: Obx(() {
            final index = selectedIndex.value;

            if (index != lastIndex) {
              // Limpia el binding anterior
              switch (lastIndex) {
                case 0:
                  if (Get.isRegistered<HomeController>()) Get.delete<HomeController>();
                  break;
                case 1:
                  if (Get.isRegistered<RevisitsController>()) Get.delete<RevisitsController>();
                  break;
                // case 2:
                //   if (Get.isRegistered<SettingsController>()) Get.delete<SettingsController>();
                //   break;
                case 2:
                  if (Get.isRegistered<PendingSurveyController>()) Get.delete<PendingSurveyController>();
                  break;
                case 3:
                  if (Get.isRegistered<SettingsController>()) Get.delete<SettingsController>();
                  break;
              }
              lastIndex = index;
            }

            switch (index) {
              case 0:
                _ensureBinding<HomeController>(index);
                break;
              case 1:
                _ensureBinding<RevisitsController>(index);
                break;
              // case 2:
              //   _ensureBinding<SettingsController>(index);
              //   break;
              case 2:
                _ensureBinding<PendingSurveyController>(index);
                break;
              case 3:
                _ensureBinding<SettingsController>(index);
                break;
            }

            return pages[index] ?? const Center(child: Text('No page found'));
          }),
          bottomNavigationBar: SizedBox(
            height: 80,
            child: Obx(() => MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: Stack(
                children: [
                  BottomNavigationBar(
                    elevation: 0,
                    backgroundColor: AppColors.background,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: AppColors.primaryButton,
                    unselectedItemColor: Colors.grey,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                    ),
                    currentIndex: selectedIndex.value,
                    onTap: (index) {
                      if (index == selectedIndex.value) return;

                      if (!loadedIndices.contains(index)) {
                        bindings[index]?.dependencies();
                        loadedIndices.add(index);
                      }

                      selectedIndex.value = index;
                    },
                    items: List.generate(navItems.length, (index) {
                      final item = navItems[index];
                      final isSelected = selectedIndex.value == index;

                      return BottomNavigationBarItem(
                        icon: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (isSelected)
                              Container(
                                height: 2,
                                width: 64,
                                color: AppColors.primaryButton,
                              ),
                            const SizedBox(height: 6),
                            Icon(item['icon'] as IconData, size: 30),
                          ],
                        ),
                        label: item['label'] as String,
                      );
                    }),
                  ),
                ],
              ),
            )),
          ),

        ),

        Obx(() {
          if (controller.isDownloadingSurveys.value && controller.connectivityService.isOnline) {
            return const Positioned.fill(child: DownloadSplash());
          }
          return const SizedBox.shrink();
        }),
      ],
    ),
    );
  }



  Widget _buildAppBar(user, bool isIOS) {
    return Container(
      padding: EdgeInsets.only(top: isIOS ? 10 : 20, right: 8, left: 8),
      decoration: const BoxDecoration(gradient: AppColors.backgroundSecondary),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: isIOS ? 50 : kToolbarHeight,
        centerTitle: false,
        titleSpacing: 0,
        title: ProfileHeader(
          name: '${user.name} ${user.surname}',
          role: 'Encuestador',
        ),
      ),
    );
  }

  void _ensureBinding<T>(int index, {bool force = false}) {
    if (force || !Get.isRegistered<T>()) {
      bindings[index]?.dependencies();
    }
  }

}
