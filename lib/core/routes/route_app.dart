
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';

class RouteApp{
  static final router = GoRouter(
    initialLocation: RouteName.loginScreen,
    routes: [
      GoRoute(
        path: RouteName.loginScreen,
        name: RouteName.loginScreen,
        builder: (context, state) {
          return const Placeholder();
        },
      ),
    ],
  );
}