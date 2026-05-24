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

  const BaseDashboardLayout({
    super.key,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: ConstantColor.backgroundColor,
      body: Obx(() {
        final username = userController.username.value;
        final role = userController.role.value;

        return Row(
          children: [
            _buildSidebar(context, username, role),
            Expanded(
              child: Column(
                children: [
                  _buildTopAppBar(context, username),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32.0),
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
                                fontFamily: 'Serif',
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                          child,
                          const SizedBox(height: 32),
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

  Widget _buildSidebar(BuildContext context, String username, String role) {
    return Container(
      width: 260,
      color: ConstantColor.surfaceColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rumah Sewa Biru Laut",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ConstantColor.textPrimaryColor,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      color: ConstantColor.textSecondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Nav Items
          _buildNavItem(Icons.dashboard, "Dashboard", isActive: true),
          _buildNavItem(Icons.business, "Properties"),
          _buildNavItem(Icons.people, "Tenants"),
          _buildNavItem(Icons.payment, "Payments"),
          _buildNavItem(Icons.build, "Maintenance"),
          _buildNavItem(Icons.settings, "Settings"),
          _buildNavItem(Icons.help, "Support"),
          
          const Spacer(),
          
          // Logout at bottom
          InkWell(
            onTap: () => _logout(context),
            child: const Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 12),
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? ConstantColor.textPrimaryColor : ConstantColor.textSecondaryColor,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? ConstantColor.textPrimaryColor : ConstantColor.textSecondaryColor,
          ),
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, String username) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: ConstantColor.backgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Date
          Text(
            "20 Oktober 2023",
            style: TextStyle(
              color: ConstantColor.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          
          // Search Bar
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari penyewa atau kamar...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 18),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 24),
          
          // Notification Icon
          Icon(Icons.notifications_none, color: ConstantColor.textSecondaryColor),
          const SizedBox(width: 24),
          
          // Logout Text Button
          TextButton(
            onPressed: () => _logout(context),
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
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
      child: Center(
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('jwt_token') ?? '';
      await authRepository.logout(token);

      await prefs.remove('jwt_token');
      await prefs.remove('user_id');
      await prefs.remove('user_username');
      await prefs.remove('user_role');
    
      if (context.mounted) {
        context.go(RouteName.loginScreen);
      }
    } catch (e) {
      print(e);
    }
  }
}
