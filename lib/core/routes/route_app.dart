import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/bindings/auth_binding.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/presentation/controllers/login_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/presentation/pages/login_screen.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/presentation/widgets/login_landing_sections.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/pages/manager_dash_page.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/pages/admin_dash_page.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/pages/tenant_dash_page.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/pages/tenant_payments_page.dart';

class RouteApp {
  static final router = GoRouter(
    initialLocation: RouteName.landingPage,
    routes: [
      GoRoute(
        path: RouteName.landingPage,
        name: RouteName.landingPage,
        builder: (context, state) => const LandingPage(),
      ),
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
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ManagerDashPage(activeMenu: "Dashboard"),
        ),
      ),
      GoRoute(
        path: RouteName.managerPropertiesPage,
        name: RouteName.managerPropertiesPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ManagerDashPage(activeMenu: "Properties"),
        ),
      ),
      GoRoute(
        path: RouteName.managerTenantsPage,
        name: RouteName.managerTenantsPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ManagerDashPage(activeMenu: "Tenants"),
        ),
      ),
      GoRoute(
        path: RouteName.managerPaymentsPage,
        name: RouteName.managerPaymentsPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ManagerDashPage(activeMenu: "Payments"),
        ),
      ),
      GoRoute(
        path: RouteName.managerMaintenancePage,
        name: RouteName.managerMaintenancePage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ManagerDashPage(activeMenu: "Maintenance"),
        ),
      ),
      GoRoute(
        path: RouteName.managerSettingsPage,
        name: RouteName.managerSettingsPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ManagerDashPage(activeMenu: "Settings"),
        ),
      ),
      GoRoute(
        path: RouteName.managerSupportPage,
        name: RouteName.managerSupportPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ManagerDashPage(activeMenu: "Support"),
        ),
      ),
      GoRoute(
        path: RouteName.adminDashPage,
        name: RouteName.adminDashPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashPage(activeMenu: "Dashboard"),
        ),
      ),
      GoRoute(
        path: RouteName.adminPropertiesPage,
        name: RouteName.adminPropertiesPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashPage(activeMenu: "Properties"),
        ),
      ),
      GoRoute(
        path: RouteName.adminTenantsPage,
        name: RouteName.adminTenantsPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashPage(activeMenu: "Tenants"),
        ),
      ),
      GoRoute(
        path: RouteName.adminPaymentsPage,
        name: RouteName.adminPaymentsPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashPage(activeMenu: "Payments"),
        ),
      ),
      GoRoute(
        path: RouteName.adminMaintenancePage,
        name: RouteName.adminMaintenancePage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashPage(activeMenu: "Maintenance"),
        ),
      ),
      GoRoute(
        path: RouteName.adminSettingsPage,
        name: RouteName.adminSettingsPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashPage(activeMenu: "Settings"),
        ),
      ),
      GoRoute(
        path: RouteName.adminSupportPage,
        name: RouteName.adminSupportPage,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashPage(activeMenu: "Support"),
        ),
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