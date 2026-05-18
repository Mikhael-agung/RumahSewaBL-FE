import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/variables.dart';
import 'package:rumah_sewa_biru_laut_fe/core/controllers/user_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(UserController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: ConstantVariable.screenSize,
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: true,
          title: ConstantVariable.appTitle,
          routerConfig: RouteApp.router,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data:mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },
        );
      },
    );
  }
}
