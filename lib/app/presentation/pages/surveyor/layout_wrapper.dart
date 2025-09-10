import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/auth_storage_service.dart';
import '../../../../core/theme/app_colors_theme.dart';

import '../../../bindings/home_binding.dart';
import '../../../bindings/settings_binding.dart';
import '../../../bindings/statistic_binding.dart';
import '../../../bindings/survey_pending_binding.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/pending_survey_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/statistic_controller.dart';

import '../../widgets/confirmation_dialog.dart';
import 'pages/home/home_page.dart';
import 'pages/home/widgets/download_splash.dart';
import 'pages/pendingSurveys/pending_surveys_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/statistic/statistic_page.dart';
import 'widgets/profile_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final RxInt selectedIndex = 0.obs;
  int lastIndex = 0;

  // Páginas por índice
  final pages = <int, Widget>{
    0: const HomePage(),
    1: const StatisticPage(),
    2: const PendingSurveysPage(),
    3: const SettingsPage(),
  };

  // Items de navegación
  final navItems = [
    {'icon': Icons.home_outlined, 'label': 'Inicio'},
    {'icon': Icons.stacked_bar_chart_outlined, 'label': 'Estadísticas'},
    {'icon': Icons.cloud_upload_outlined, 'label': 'En cola'},
    {'icon': Icons.settings_outlined, 'label': 'Ajustes'},
  ];

  // Bindings por índice
  final bindings = <int, Bindings>{
    0: HomeBinding(),
    1: StatisticBinding(),
    2: PendingSurveyBinding(),
    3: SettingsBinding(),
  };

  @override
  void initState() {
    super.initState();
    // Cargamos la primera pestaña
    bindings[0]?.dependencies();
  }

  Future<bool> _onWillPop() async {
    final confirmed = await Get.dialog<bool>(
      const ConfirmationDialog(
        message: '¿Estás seguro de que deseas salir de la aplicación?',
        confirmText: 'Salir',
      ),
    );
    return confirmed ?? false;
  }

  void _onTabSelected(int index) {
    if (index == selectedIndex.value) return;

    // Limpia el controller del índice anterior (si existe)
    switch (lastIndex) {
      case 0:
        if (Get.isRegistered<HomeController>()) Get.delete<HomeController>();
        break;
      case 1:
        if (Get.isRegistered<StatisticController>()) Get.delete<StatisticController>();
        break;
      case 2:
        if (Get.isRegistered<PendingSurveyController>()) Get.delete<PendingSurveyController>();
        break;
      case 3:
        if (Get.isRegistered<SettingsController>()) Get.delete<SettingsController>();
        break;
    }

    bindings[index]?.dependencies();

    selectedIndex.value = index;
    lastIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    final user = Get.find<AuthStorageService>().authResponse!;

    final HomeController? homeCtrl =
    Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: scheme.firstBackground,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: _buildAppBar(user, isIOS, scheme),
            ),
            body: Obx(() => pages[selectedIndex.value] ??
                const Center(child: Text('No page found'))),
            bottomNavigationBar: SizedBox(
              height: 80,
              child: Obx(() => MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: _buildBottomNavBar(scheme),
              )),
            ),
          ),

          if (homeCtrl != null)
            Obx(() {
              if (homeCtrl.isDownloadingSurveys.value &&
                  homeCtrl.connectivityService.isOnline) {
                return const Positioned.fill(child: DownloadSplash());
              }
              return const SizedBox.shrink();
            }),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(AppColorScheme scheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.firstBackground,
        border: Border(
          top: BorderSide(color: scheme.border.withOpacity(isDark ? 0.30 : 0.55)),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex.value,
        selectedItemColor: scheme.iconBackground,
        unselectedItemColor: scheme.secondaryText.withOpacity(0.70),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
        onTap: _onTabSelected,
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
                    color: scheme.iconBackground,
                  ),
                const SizedBox(height: 6),
                Icon(item['icon'] as IconData, size: 28),
              ],
            ),
            label: item['label'] as String,
          );
        }),
      ),
    );
  }

  Widget _buildAppBar(dynamic user, bool isIOS, AppColorScheme scheme) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: top + (isIOS ? 6 : 10),
        right: 16,
        left: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        gradient: AppColorScheme.headerGradient, // gradiente de marca
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
      ),
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
          avatar: const AssetImage('assets/images/icons/user.png'),
        ),
      ),
    );
  }
}
