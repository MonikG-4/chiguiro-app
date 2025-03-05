import 'package:get/get.dart';
import '../../core/middleware/session_middleware.dart';
import '../../core/values/routes.dart';
import '../bindings/auth_binding.dart';
import '../bindings/dashboard_surveyor_binding.dart';
import '../bindings/detail_survey_binding.dart';
import '../bindings/survey_binding.dart';
import '../presentation/pages/changePassword/change_password_page.dart';
import '../presentation/pages/forgotPassword/forgot_password_page.dart';
import '../presentation/pages/surveyor/dashboard_surveyor_page.dart';
import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/surveyor/pages/survey/survey_page.dart';
import '../presentation/pages/surveyor/pages/surveyDetail/survey_detail_page.dart';
import '../presentation/pages/surveyor/pages/surveyWithoutResponses/survey_without_responses_page.dart';

class AppPages {
  static final routes = [
    GetPage(
        name: Routes.DASHBOARD_SURVEYOR,
        page: () => const DashboardSurveyorPage(),
        middlewares: [SessionMiddleware()],
        binding: DashboardSurveyorBinding()),
    GetPage(
      name: Routes.SURVEY_WITHOUT_RESPONSE,
      page: () => const SurveyWithoutResponsesPage(),
      middlewares: [SessionMiddleware()],
    ),
    GetPage(
        name: Routes.SURVEY_DETAIL,
        page: () => const SurveyDetailPage(),
        middlewares: [SessionMiddleware()],
        binding: DetailSurveyBinding()),
    GetPage(
        name: Routes.SURVEY,
        page: () => SurveyPage(),
        middlewares: [SessionMiddleware()],
        binding: SurveyBinding()),
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
        page: () => const ChangePasswordPage(),
        middlewares: [SessionMiddleware()],
        binding: AuthBinding()),
  ];
}