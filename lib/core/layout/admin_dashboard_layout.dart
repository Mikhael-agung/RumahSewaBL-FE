import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/admin_colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/core/controllers/user_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/global_notification_service.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/bindings/auth_binding.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/domain/repositories/auth_repository.dart';

/// Shell layout khusus modul Admin (sidebar + top app bar).
/// Terpisah dari [BaseDashboardLayout] (dipakai Manager) supaya style
/// admin (Material 3 look, palet [AdminColors], font Manrope/Inter)
/// bisa dikembangkan sendiri.
class AdminDashboardLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final String activeMenu;

  const AdminDashboardLayout({
    super.key,
    required this.child,
    required this.activeMenu,
    this.title,
  });

  static const _navItems = <_AdminNavItem>[
    _AdminNavItem(Icons.dashboard_outlined, Icons.dashboard, "Dashboard", RouteName.adminDashPage),
    _AdminNavItem(Icons.history_outlined, Icons.history, "Activity Log", RouteName.adminActivityLogPage),
    _AdminNavItem(Icons.domain_outlined, Icons.domain, "Properties", RouteName.adminPropertiesPage),
    _AdminNavItem(Icons.groups_outlined, Icons.groups, "Tenants", RouteName.adminTenantsPage),
    _AdminNavItem(Icons.payments_outlined, Icons.payments, "Payments", RouteName.adminPaymentsPage),
    _AdminNavItem(Icons.build_outlined, Icons.build, "Maintenance", RouteName.adminMaintenancePage),
    _AdminNavItem(Icons.settings_outlined, Icons.settings, "Settings", RouteName.adminSettingsPage),
    _AdminNavItem(Icons.help_outline, Icons.help, "Support", RouteName.adminSupportPage),
  ];

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final isMobile = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: AdminColors.background,
      drawer: isMobile
          ? Drawer(
              width: 260,
              child: _buildSidebar(context, userController, isMobile),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context, userController, isMobile),
          Expanded(
            child: Column(
              children: [
                _buildTopAppBar(context, userController, isMobile),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16.0 : 32.0,
                      vertical: isMobile ? 20.0 : 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null) ...[
                          Text(
                            title!,
                            style: GoogleFonts.manrope(
                              fontSize: isMobile ? 26 : 34,
                              fontWeight: FontWeight.w800,
                              color: AdminColors.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: isMobile ? 20 : 32),
                        ],
                        child,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    UserController userController,
    bool isMobile,
  ) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: AdminColors.surfaceContainerHigh, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Brand
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AdminColors.primary, AdminColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "R",
                    style: GoogleFonts.manrope(
                      color: AdminColors.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rumah Sewa Biru Laut",
                        maxLines: 2,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          height: 1.15,
                          color: AdminColors.primary,
                        ),
                      ),
                      Text(
                        "Administrator Aktif",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AdminColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Nav items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final item in _navItems)
                  _buildNavItem(
                    context,
                    item,
                    activeMenu == item.label,
                    isMobile,
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: AdminColors.outlineVariant),
          const SizedBox(height: 8),
          _buildNavTile(
            icon: Icons.logout,
            label: "Logout",
            isActive: false,
            color: AdminColors.error,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    _AdminNavItem item,
    bool isActive,
    bool isMobile,
  ) {
    return _buildNavTile(
      icon: isActive ? item.filledIcon : item.icon,
      label: item.label,
      isActive: isActive,
      onTap: () {
        if (isMobile) Navigator.pop(context);
        if (!isActive) context.go(item.route);
      },
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? AdminColors.primaryFixed : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 22,
          color: color ?? (isActive ? AdminColors.primary : AdminColors.onSurfaceVariant),
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: color ?? (isActive ? AdminColors.primary : AdminColors.onSurfaceVariant),
          ),
        ),
        dense: true,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }

  Widget _buildTopAppBar(
    BuildContext context,
    UserController userController,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLow.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: AdminColors.surfaceContainerHigh, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AdminColors.onSurface),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          else
            Icon(Icons.search, color: AdminColors.onSurfaceVariant),
          const Spacer(),
          _buildNotificationIcon(context),
          const SizedBox(width: 20),
          Obx(() {
            final username = userController.username.value.isNotEmpty
                ? userController.username.value
                : "Admin";
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AdminColors.primaryFixed,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : "A",
                    style: GoogleFonts.manrope(
                      color: AdminColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 10),
                  Text(
                    username,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.onSurface,
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    if (!Get.isRegistered<GlobalNotificationService>()) {
      return Icon(Icons.notifications_outlined, color: AdminColors.onSurfaceVariant);
    }
    final notificationService = Get.find<GlobalNotificationService>();
    return Obx(() {
      final hasUnread = notificationService.unreadCount.value > 0;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, color: AdminColors.onSurfaceVariant),
          if (hasUnread)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AdminColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      );
    });
  }

  Future<void> _logout(BuildContext context) async {
    if (!Get.isRegistered<AuthRepository>()) {
      AuthBinding().dependencies();
    }
    final authRepository = Get.find<AuthRepository>();
    final userController = Get.find<UserController>();

    Future<void> clearLocalSession() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('user_id');
      await prefs.remove('user_username');
      await prefs.remove('user_role');
      userController.clearUserData();
      if (Get.isRegistered<GlobalNotificationService>()) {
        await Get.find<GlobalNotificationService>().stopPolling(clearState: true);
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('jwt_token') ?? '';
      await authRepository.logout(token);
      await clearLocalSession();
    } catch (_) {
      await clearLocalSession();
    }

    if (context.mounted) {
      context.go(RouteName.loginScreen);
    }
  }
}

class _AdminNavItem {
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final String route;

  const _AdminNavItem(this.icon, this.filledIcon, this.label, this.route);
}