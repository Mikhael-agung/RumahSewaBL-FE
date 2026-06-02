import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/layout/base_dashboard_layout.dart';
import 'package:rumah_sewa_biru_laut_fe/core/controllers/user_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/dashboard_content_view.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/properties_content_view.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/tenants_content_view.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/payments_content_view.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/maintenance_content_view.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/settings_content_view.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/support_content_view.dart';

class ManagerDashPage extends StatelessWidget {
  final String activeMenu;

  const ManagerDashPage({
    super.key,
    required this.activeMenu,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return BaseDashboardLayout(
      activeMenu: activeMenu,
      child: Obx(() {
        final username = userController.username.value.isNotEmpty 
            ? userController.username.value 
            : "Rina Hartati";

        switch (activeMenu) {
          case 'Dashboard':
            return DashboardContentView(username: username);
          case 'Properties':
            return const PropertiesContentView();
          case 'Tenants':
            return const TenantsContentView();
          case 'Payments':
            return const PaymentsContentView();
          case 'Maintenance':
            return const MaintenanceContentView();
          case 'Settings':
            return const SettingsContentView();
          case 'Support':
            return const SupportContentView();
          default:
            return DashboardContentView(username: username);
        }
      }),
    );
  }
}
