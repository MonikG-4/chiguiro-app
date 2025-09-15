import 'package:get/get.dart';
import '../../core/values/routes.dart';
import '../bindings/auth_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/permission_binding.dart';
import '../bindings/survey_binding.dart';
import '../presentation/pages/forgotPassword/forgot_password_page.dart';
import '../presentation/pages/surveyor/dashboard_page.dart';
import '../presentation/pages/surveyor/pages/home/home_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/surveyor/pages/pendingSurveys/pending_surveys_page.dart';
import '../presentation/pages/surveyor/pages/settings/pages/accessibility/accessibility_page.dart';
import '../presentation/pages/surveyor/pages/settings/pages/changePassword/change_password_page.dart';
import '../presentation/pages/surveyor/pages/settings/pages/permissions/permission_detail_wrapper.dart';
import '../presentation/pages/surveyor/pages/settings/pages/permissions/permissions_page.dart';
import '../presentation/pages/surveyor/pages/settings/pages/profile/profile_page.dart';
import '../presentation/pages/surveyor/pages/settings/settings_page.dart';
import '../presentation/pages/surveyor/pages/statistic/statistic_page.dart';
import '../presentation/pages/surveyor/pages/survey/survey_page.dart';
import '../presentation/pages/surveyor/pages/surveyWithoutResponses/survey_without_responses_page.dart';

class AppPages {
  static final routes = [
    // Auth pages
    GetPage(
        name: Routes.LOGIN,
        page: () => const LoginPage(),
        binding: AuthBinding()
    ),
    GetPage(
        name: Routes.FORGOT_PASSWORD,
        page: () => const ForgotPasswordPage(),
        binding: AuthBinding()
    ),

    // Dashboard
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD_HOME,
      page: () => const HomePage(),
    ),
    GetPage(
      name: Routes.DASHBOARD_PENDING_SURVEYS,
      page: () => const PendingSurveysPage(),
    ),
    GetPage(
      name: Routes.DASHBOARD_STATISTICS,
      page: () => const StatisticPage(),
    ),
    GetPage(
      name: Routes.DASHBOARD_SETTINGS,
      page: () => const SettingsPage(),
    ),

    // Survey Pages
    GetPage(
      name: Routes.SURVEY,
      page: () => SurveyPage(),
      transition: Transition.cupertino,
      popGesture: false,
      binding: SurveyBinding(),
    ),
    GetPage(
      name: Routes.SURVEY_WITHOUT_RESPONSE,
      page: () => SurveyWithoutResponsesPage(),
    ),

    // Settings Pages
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: Routes.ACCESSIBILITY,
      page: () => const AccessibilityPage(),
    ),
    GetPage(
        name: Routes.CHANGE_PASSWORD,
        page: () => const ChangePasswordPage(),
    ),
    GetPage(
      name: Routes.PERMISSIONS,
      page: () => const PermissionsPage(),
      binding: PermissionBinding(),
    ),
    GetPage(
      name: Routes.PERMISSION_DETAIL,
      page: () => const PermissionDetailWrapper(),
    ),

  ];
}
