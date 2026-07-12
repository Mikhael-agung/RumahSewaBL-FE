import 'package:flutter/material.dart';
import 'package:rumah_sewa_biru_laut_fe/core/layout/admin_dashboard_layout.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/admin/activity_log_content_view.dart';

/// Page Activity Log (admin-only). Sengaja dipisah dari [AdminDashPage]
/// (belum stabil, masih dikerjakan) supaya fitur ini bisa jalan sendiri
/// tanpa ikut ketarik saat AdminDashPage disambungkan ke
/// [AdminDashboardLayout] nanti.
class AdminActivityLogPage extends StatelessWidget {
  const AdminActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDashboardLayout(
      activeMenu: "Activity Log",
      title: "Activity Log",
      child: ActivityLogContentView(),
    );
  }
}