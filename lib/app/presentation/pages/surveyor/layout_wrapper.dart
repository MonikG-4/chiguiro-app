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

  final Map<int, Bindings> _bindings = {
    0: HomeBinding(),
    1: StatisticBinding(),
    2: PendingSurveyBinding(),
    3: SettingsBinding(),
  };

  late final Map<int, WidgetBuilder> _pageBuilders = {
    0: (_) => const HomePage(),
    1: (_) => const StatisticPage(),
    2: (_) => const PendingSurveysPage(),
    3: (_) => const SettingsPage(),
  };

  void _disposeTab(int index) {
    void _deleteIf<T>() {
      if (Get.isRegistered<T>()) Get.delete<T>(force: true);
    }

    switch (index) {
      case 0: _deleteIf<HomeController>(); break;
      case 1: _deleteIf<StatisticController>(); break;
      case 2: _deleteIf<PendingSurveyController>(); break;
      case 3: _deleteIf<SettingsController>(); break;
      default: break;
    }
  }

  void _cleanupAll() {
    for (final i in [0, 1, 2, 3]) {
      _disposeTab(i);
    }
  }

  @override
  void initState() {
    super.initState();
    _bindings[0]?.dependencies();
  }

  Future<bool> _onWillPop() async {
    final confirmed = await Get.dialog<bool>(
      const ConfirmationDialog(
        message: '¿Estás seguro de que deseas salir de la aplicación?',
        confirmText: 'Salir',
      ),
    );
    if (confirmed == true) {
      _cleanupAll();
      Get.closeAllSnackbars();
    }
    return confirmed ?? false;
  }

  void _onTabSelected(int index) {
    if (index == selectedIndex.value) return;

    _disposeTab(lastIndex);

    _bindings[index]?.dependencies();

    selectedIndex.value = index;
    lastIndex = index;
  }

  @override
  void dispose() {
    _cleanupAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    final user = Get.find<AuthStorageService>().authResponse!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: scheme.firstBackground,
            appBar: _buildAppBar(user, scheme),
            body: Obx(() {
              final builder = _pageBuilders[selectedIndex.value];
              return builder != null
                  ? builder(context)
                  : const Center(child: Text('No page found'));
            }),
            bottomNavigationBar: SizedBox(
              height: 80,
              child: Obx(() => MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: _buildBottomNavBar(scheme),
              )),
            ),
          ),

          Obx(() {
            if (!Get.isRegistered<HomeController>()) {
              return const SizedBox.shrink();
            }
            final homeCtrl = Get.find<HomeController>();
            final show = homeCtrl.isDownloadingSurveys.value &&
                homeCtrl.connectivityService.isOnline;
            return show ? const Positioned.fill(child: DownloadSplash())
                : const SizedBox.shrink();
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
          top: BorderSide(
            color: scheme.border.withOpacity(isDark ? 0.30 : 0.55),
          ),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex.value,
        selectedItemColor: scheme.iconBackground,
        unselectedItemColor: scheme.secondaryText.withOpacity(0.70),
        selectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: _NavIcon(icon: Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(icon: Icons.stacked_bar_chart_outlined),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(icon: Icons.cloud_upload_outlined),
            label: 'En cola',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(icon: Icons.settings_outlined),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(dynamic user, AppColorScheme scheme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColorScheme.headerGradient,
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 16,
          toolbarHeight: 110,
          title: ProfileHeader(
            name: '${user.name} ${user.surname}',
            role: 'Encuestador',
            avatar: const AssetImage('assets/images/icons/user.png'),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  const _NavIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    final bnc = context.findAncestorWidgetOfExactType<BottomNavigationBar>();
    final selectedIndex = (bnc?.currentIndex ?? 0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (DefaultTextStyle.of(context).style.fontWeight == FontWeight.bold)
          Container(height: 2, width: 64, color: scheme.iconBackground),
        const SizedBox(height: 6),
        Icon(icon, size: 28),
      ],
    );
  }
}
