import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/bindings/auth_binding.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/presentation/controllers/login_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/presentation/pages/login_screen.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/pages/manager_dash_page.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/pages/admin_dash_page.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/pages/tenant_dash_page.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/pages/tenant_payments_page.dart';

class RouteApp{
  static final router = GoRouter(
    initialLocation: RouteName.loginScreen,
    routes: [
      GoRoute(
        path: RouteName.loginScreen,
        name: RouteName.loginScreen,
        builder: (context, state) {
          AuthBinding().dependencies();
          Get.find<LoginController>().loadSavedCredentials();
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: RouteName.managerDashPage,
        name: RouteName.managerDashPage,
        builder: (context, state) {
          return const ManagerDashPage();
        },
      ),
      GoRoute(
        path: RouteName.adminDashPage,
        name: RouteName.adminDashPage,
        builder: (context, state) {
          return const AdminDashPage();
        },
      ),
      GoRoute(
        path: RouteName.tenantDashPage,
        name: RouteName.tenantDashPage,
        builder: (context, state) {
          return const TenantDashPage();
        },
      ),
      GoRoute(
        path: RouteName.tenantPaymentsPage,
        name: RouteName.tenantPaymentsPage,
        builder: (context, state) {
          return const TenantPaymentsPage();
        },
      ),
    ],
  );
}