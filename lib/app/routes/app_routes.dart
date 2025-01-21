import 'package:get/get.dart';
import '../../core/middleware/session_middleware.dart';
import '../../core/values/routes.dart';
import '../bindings/auth_binding.dart';
import '../bindings/dashboard_surveyor_binding.dart';
import '../presentation/pages/changePassword/change_password.dart';
import '../presentation/pages/forgotPassword/forgot_password_page.dart';
import '../presentation/pages/surveyor/dashboard_surveyor_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/surveyor/pages/surveyDetail/survey_detail.dart';
import '../presentation/pages/surveyor/pages/surveyWithoutResponses/survey_without_responses.dart';

class AppPages {
  static final routes = [
    GetPage(
        name: Routes.DASHBOARD_SURVEYOR,
        page: () => const DashboardSurveyorPage(),
        middlewares: [SessionMiddleware()],
        binding: DashboardSurveyorBinding()),
    GetPage(
      name: Routes.SURVEY_WITHOUT_RESPONSE,
      page: () => const SurveyWithoutResponses(),
      middlewares: [SessionMiddleware()],
    ),
    GetPage(
        name: Routes.SURVEY_DETAIL,
        page: () => SurveyDetail(),
        middlewares: [SessionMiddleware()]),
    GetPage(
        name: Routes.LOGIN,
        page: () => const LoginPage(),
        binding: AuthBinding()),
    GetPage(
        name: Routes.FORGOT_PASSWORD,
        page: () => const ForgotPasswordPage(),
        binding: AuthBinding()),
    GetPage(
        name: Routes.CHANGE_PASSWORD,
        page: () => const ChangePassword(),
        middlewares: [SessionMiddleware()],
        binding: AuthBinding()),
  ];
}
