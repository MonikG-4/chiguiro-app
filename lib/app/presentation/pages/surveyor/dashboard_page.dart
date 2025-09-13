import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../core/services/auth_storage_service.dart';
import '../../../../core/theme/app_colors_theme.dart';
import '../../../../core/values/routes.dart';
import '../../../routes/app_pages.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/confirmation_dialog.dart';
import 'pages/home/widgets/download_splash.dart';
import 'widgets/profile_header.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final RxInt currentIndex = 0.obs;
  late final PersistentTabController _controller;

  static const List<Map<String, dynamic>> navItems = [
    {"route": Routes.DASHBOARD_HOME, "icon": Icons.home_outlined, "label": "Inicio"},
    {"route": Routes.DASHBOARD_STATISTICS, "icon": Icons.stacked_bar_chart_outlined, "label": "Estadísticas"},
    {"route": Routes.DASHBOARD_PENDING_SURVEYS, "icon": Icons.cloud_upload_outlined, "label": "En cola"},
    {"route": Routes.DASHBOARD_SETTINGS, "icon": Icons.settings_outlined, "label": "Ajustes"},
  ];

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(() => currentIndex.value = _controller.index);
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

  List<Widget> _buildScreens() {
    return navItems.map((navItem) {
      final pageConfig = AppPages.routes.firstWhereOrNull(
            (r) => r.name == navItem["route"],
      );
      return pageConfig?.page() ?? const Center(child: Text("Página no encontrada"));
    }).toList();
  }


  List<PersistentBottomNavBarItem> _navBarsItems(int indexSelected) {
    final scheme = Theme.of(context).extension<AppColorScheme>()!;
    return navItems.map((item) {
      return PersistentBottomNavBarItem(
        icon: Icon(item["icon"]),
        title: item["label"],
        activeColorPrimary: scheme.iconBackground,
        inactiveColorPrimary: const Color(0xFF888888),
      );
    }).toList();
  }

  PreferredSizeWidget _buildAppBar() {
    if (!Get.isRegistered<AuthStorageService>() ||
        Get.find<AuthStorageService>().authResponse == null) {
      return AppBar(backgroundColor: Colors.transparent, elevation: 0);
    }

    final user = Get.find<AuthStorageService>().authResponse!;
    return PreferredSize(
      preferredSize: const Size.fromHeight(110),
      child: Container(
        decoration: const BoxDecoration(gradient: AppColorScheme.headerGradient),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
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

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();

    return Obx(() {
      if (homeCtrl.isSurveysLoading.value) {
        return const DownloadSplash();
      }

      // Render normal con WillPopScope
      final scheme = Theme.of(context).extension<AppColorScheme>()!;
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: PersistentTabView(
            context,
            controller: _controller,
            screens: _buildScreens(),
            items: _navBarsItems(currentIndex.value),
            confineToSafeArea: true,
            backgroundColor: scheme.firstBackground,
            handleAndroidBackButtonPress: true,
            resizeToAvoidBottomInset: true,
            stateManagement: true,
            hideNavigationBarWhenKeyboardAppears: true,
            animationSettings: const NavBarAnimationSettings(
              navBarItemAnimation: ItemAnimationSettings(
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              ),
              screenTransitionAnimation: ScreenTransitionAnimationSettings(
                animateTabTransition: true,
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 250),
              ),
            ),
            decoration: const NavBarDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
            navBarStyle: NavBarStyle.style3,
          ),
        ),
      );
    });
  }

}
