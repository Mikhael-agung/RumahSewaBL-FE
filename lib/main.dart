import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/variables.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/controllers/user_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_app.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_bloc.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';

import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/global_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ApiService(), permanent: true);
  Get.put(UserController(), permanent: true);
  final notificationService = Get.put(
    GlobalNotificationService(),
    permanent: true,
  );
  await notificationService.initialize();
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
        return MultiBlocProvider(
          providers: [
            BlocProvider<PaymentsBloc>(
              create: (_) =>
                  PaymentsBloc(repository: PaymentsRepository())
                    ..add(const PaymentsFetched()),
            ),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: true,
            title: ConstantVariable.appTitle,
            scaffoldMessengerKey: ConstantVariable.scaffoldMessengerKey,
            routerConfig: RouteApp.router,
            theme: ThemeData(
              primaryColor: ConstantColor.primaryColor,
              fontFamily: 'Inter',
              scaffoldBackgroundColor: const Color(0xFFF8F9FF),
            ),
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          ),
        );
      },
    );
  }
}
