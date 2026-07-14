import 'package:flutter/material.dart';

class ConstantVariable {
  ConstantVariable._();
  // contex
  static final GlobalKey<NavigatorState> snavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static String appTitle = "Rumah Sewa Biru Laut";
  static String appSubTitle = "Mencari Rumah Sewa? Di sini Tempatnya.";
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://rumahsewabl-be-production-v2.up.railway.app',
  );
  static String get apiBaseUrl => '$baseUrl/api';
  static Duration connectTimeout = Duration(seconds: 10);
  static Duration receiveTimeout = Duration(seconds: 10);
  static Size screenSize = const Size(375, 812);
}
