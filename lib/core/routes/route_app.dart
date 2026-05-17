import 'package:go_router/go_router.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/bindings/auth_binding.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/presentation/pages/login_screen.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/pages/dashboard_screen.dart';

class RouteApp{
  static final router = GoRouter(
    initialLocation: RouteName.loginScreen,
    routes: [
      GoRoute(
        path: RouteName.loginScreen,
        name: RouteName.loginScreen,
        builder: (context, state) {
          // Initialize dependencies for Auth feature
          AuthBinding().dependencies();
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: RouteName.dashboardScreen,
        name: RouteName.dashboardScreen,
        builder: (context, state) {
          return const DashboardScreen();
        },
      ),
    ],
  );
}