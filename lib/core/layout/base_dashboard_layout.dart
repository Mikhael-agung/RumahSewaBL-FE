import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/core/controllers/user_controller.dart';

class BaseDashboardLayout extends StatelessWidget {
  final Widget child;
  final String? title; // Optional title for the main content area
  final String? activeMenu; // Optional active menu for sidebar highlighting

  const BaseDashboardLayout({
    super.key,
    required this.child,
    this.title,
    this.activeMenu,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: ConstantColor.backgroundColor,
      body: Obx(() {
        final username = userController.username.value;
        final role = userController.role.value;
        final currentActiveMenu = activeMenu ?? userController.activeMenu.value;

        // Capitalize role for display
        final displayRole = role.isNotEmpty 
            ? "${role[0].toUpperCase()}${role.substring(1).toLowerCase()} Aktif" 
            : "Manager Aktif";

        return Row(
          children: [
            _buildSidebar(context, username, displayRole, currentActiveMenu, userController),
            Expanded(
              child: Column(
                children: [
                  _buildTopAppBar(context, username),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null) ...[
                            Text(
                              title!,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: ConstantColor.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                          child,
                          const SizedBox(height: 48),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSidebar(BuildContext context, String username, String role, String activeMenu, UserController userController) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: ConstantColor.surfaceColor,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rumah Sewa Biru Laut",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ConstantColor.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 32),
          
          // User Profile Section
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0077B6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      username.isNotEmpty ? username : "Rina Hartati",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ConstantColor.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(Icons.dashboard_outlined, "Dashboard", activeMenu == "Dashboard", () {
                  if (userController.isManager) {
                    context.go(RouteName.managerDashPage);
                  } else {
                    userController.changeMenu("Dashboard");
                  }
                }),
                _buildNavItem(Icons.business_outlined, "Properties", activeMenu == "Properties", () {
                  if (userController.isManager) {
                    context.go(RouteName.managerPropertiesPage);
                  } else {
                    userController.changeMenu("Properties");
                  }
                }),
                _buildNavItem(Icons.people_outline, "Tenants", activeMenu == "Tenants", () {
                  if (userController.isManager) {
                    context.go(RouteName.managerTenantsPage);
                  } else {
                    userController.changeMenu("Tenants");
                  }
                }),
                _buildNavItem(Icons.payment_outlined, "Payments", activeMenu == "Payments", () {
                  if (userController.isManager) {
                    context.go(RouteName.managerPaymentsPage);
                  } else {
                    userController.changeMenu("Payments");
                  }
                }),
                _buildNavItem(Icons.build_outlined, "Maintenance", activeMenu == "Maintenance", () {
                  if (userController.isManager) {
                    context.go(RouteName.managerMaintenancePage);
                  } else {
                    userController.changeMenu("Maintenance");
                  }
                }),
                _buildNavItem(Icons.settings_outlined, "Settings", activeMenu == "Settings", () {
                  if (userController.isManager) {
                    context.go(RouteName.managerSettingsPage);
                  } else {
                    userController.changeMenu("Settings");
                  }
                }),
                _buildNavItem(Icons.help_outline, "Support", activeMenu == "Support", () {
                  if (userController.isManager) {
                    context.go(RouteName.managerSupportPage);
                  } else {
                    userController.changeMenu("Support");
                  }
                }),
              ],
            ),
          ),
          
          // Logout at the very bottom
          InkWell(
            onTap: () => _logout(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isActive, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? ConstantColor.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.white : ConstantColor.textSecondaryColor,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? Colors.white : ConstantColor.textSecondaryColor,
          ),
        ),
        dense: true,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, String username) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Date
          const Text(
            "20 Oktober 2023",
            style: TextStyle(
              color: ConstantColor.textSecondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          
          // Search Bar
          Container(
            width: 320,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari penyewa atau kamar...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
              ),
            ),
          ),
          const SizedBox(width: 24),
          
          // Notification Icon with red dot badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: ConstantColor.textSecondaryColor),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          
          // Logout Button
          OutlinedButton(
            onPressed: () => _logout(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(
                color: ConstantColor.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: const Center(
        child: Text(
          "© 2024 Rumah Sewa Biru Laut. Rooted in Comfort.",
          style: TextStyle(
            color: ConstantColor.textSecondaryColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authRepository = Get.find<AuthRepository>();
    final userController = Get.find<UserController>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('jwt_token') ?? '';
      await authRepository.logout(token);

      await prefs.remove('jwt_token');
      await prefs.remove('user_id');
      await prefs.remove('user_username');
      await prefs.remove('user_role');
    
      userController.clearUserData();
      userController.changeMenu("Dashboard"); // Reset active menu

      if (context.mounted) {
        context.go(RouteName.loginScreen);
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('user_id');
      await prefs.remove('user_username');
      await prefs.remove('user_role');
      userController.clearUserData();
      userController.changeMenu("Dashboard");
      if (context.mounted) {
        context.go(RouteName.loginScreen);
      }
    }
  }
}
