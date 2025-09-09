import 'package:get/get.dart';
import '../../core/middleware/session_middleware.dart';
import '../../core/values/routes.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/statistic_binding.dart';
import '../bindings/survey_pending_binding.dart';
import '../bindings/survey_binding.dart';
import '../presentation/controllers/permissions_controller.dart';
import '../presentation/pages/forgotPassword/forgot_password_page.dart';
import '../presentation/pages/surveyor/layout_wrapper.dart';
import '../presentation/pages/surveyor/pages/home/home_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/surveyor/pages/pendingSurveys/pending_surveys_page.dart';
import '../presentation/pages/surveyor/pages/settings/pages/changePassword/change_password_page.dart';
import '../presentation/pages/surveyor/pages/settings/pages/permissions/permission_detail_wrapper.dart';
import '../presentation/pages/surveyor/pages/settings/pages/permissions/permissions_page.dart';
import '../presentation/pages/surveyor/pages/settings/pages/profile/profile_page.dart';
import '../presentation/pages/surveyor/pages/statistic/statistic_page.dart';
import '../presentation/pages/surveyor/pages/survey/survey_page.dart';
import '../presentation/pages/surveyor/pages/surveyWithoutResponses/survey_without_responses_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardPage(),
    ),
    GetPage(
      name: Routes.DASHBOARD_HOME,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD_PENDING_SURVEYS,
      page: () => const PendingSurveysPage(),
      binding: PendingSurveyBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD_STATISTICS,
      page: () => const StatisticPage(),
      binding: StatisticBinding(),
    ),
    GetPage(
      name: Routes.SURVEY_WITHOUT_RESPONSE,
      page: () => SurveyWithoutResponsesPage(),
      middlewares: [SessionMiddleware()],
    ),
    GetPage(
        name: Routes.SURVEY,
        page: () => SurveyPage(),
        transition: Transition.cupertino,
        popGesture: false,
        middlewares: [SessionMiddleware()],
        binding: SurveyBinding()),
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
    GetPage(
        name: Routes.CHANGE_PASSWORD,
        page: () => const ChangePasswordPage(),
        middlewares: [SessionMiddleware()],
        binding: HomeBinding()
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: Routes.PERMISSIONS,
      page: () => const PermissionsPage(),
      binding: BindingsBuilder(() {
        Get.put(PermissionsController());
      }),
    ),
    GetPage(
      name: Routes.PERMISSION_DETAIL,
      page: () => const PermissionDetailWrapper(),
    ),

  ];
}
