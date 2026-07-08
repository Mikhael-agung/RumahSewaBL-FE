import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/bindings/auth_binding.dart';
import 'package:rumah_sewa_biru_laut_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/core/controllers/user_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/global_notification_service.dart';

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
    final isMobile = MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: ConstantColor.backgroundColor,
      drawer: isMobile
          ? Obx(() {
              final username = userController.username.value;
              final role = userController.role.value;
              final currentActiveMenu =
                  activeMenu ?? userController.activeMenu.value;
              final displayRole = role.isNotEmpty
                  ? "${role[0].toUpperCase()}${role.substring(1).toLowerCase()} Aktif"
                  : "Manager Aktif";
              return Drawer(
                width: 260,
                child: _buildSidebar(
                  context,
                  username,
                  displayRole,
                  currentActiveMenu,
                  userController,
                  isMobile,
                ),
              );
            })
          : null,
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
            if (!isMobile)
              _buildSidebar(
                context,
                username,
                displayRole,
                currentActiveMenu,
                userController,
                isMobile,
              ),
            Expanded(
              child: Column(
                children: [
                  _buildTopAppBar(context, username, isMobile),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : 40.0,
                        vertical: isMobile ? 20.0 : 32.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null) ...[
                            Text(
                              title!,
                              style: TextStyle(
                                fontSize: isMobile ? 24 : 32,
                                fontWeight: FontWeight.bold,
                                color: ConstantColor.textPrimaryColor,
                              ),
                            ),
                            SizedBox(height: isMobile ? 20 : 32),
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

  Widget _buildSidebar(
    BuildContext context,
    String username,
    String role,
    String activeMenu,
    UserController userController,
    bool isMobile,
  ) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: ConstantColor.surfaceColor,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
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
                _buildNavItem(
                  Icons.dashboard_outlined,
                  "Dashboard",
                  activeMenu == "Dashboard",
                  () {
                    if (isMobile) Navigator.pop(context);
                    if (userController.isManager) {
                      context.go(RouteName.managerDashPage);
                    } else {
                      userController.changeMenu("Dashboard");
                    }
                  },
                ),
                _buildNavItem(
                  Icons.business_outlined,
                  "Properties",
                  activeMenu == "Properties",
                  () {
                    if (isMobile) Navigator.pop(context);
                    if (userController.isManager) {
                      context.go(RouteName.managerPropertiesPage);
                    } else {
                      userController.changeMenu("Properties");
                    }
                  },
                ),
                _buildNavItem(
                  Icons.people_outline,
                  "Tenants",
                  activeMenu == "Tenants",
                  () {
                    if (isMobile) Navigator.pop(context);
                    if (userController.isManager) {
                      context.go(RouteName.managerTenantsPage);
                    } else {
                      userController.changeMenu("Tenants");
                    }
                  },
                ),
                _buildNavItem(
                  Icons.payment_outlined,
                  "Payments",
                  activeMenu == "Payments",
                  () {
                    if (isMobile) Navigator.pop(context);
                    if (userController.isManager) {
                      context.go(RouteName.managerPaymentsPage);
                    } else {
                      userController.changeMenu("Payments");
                    }
                  },
                ),
                _buildNavItem(
                  Icons.build_outlined,
                  "Maintenance",
                  activeMenu == "Maintenance",
                  () {
                    if (isMobile) Navigator.pop(context);
                    if (userController.isManager) {
                      context.go(RouteName.managerMaintenancePage);
                    } else {
                      userController.changeMenu("Maintenance");
                    }
                  },
                ),
                _buildNavItem(
                  Icons.settings_outlined,
                  "Settings",
                  activeMenu == "Settings",
                  () {
                    if (isMobile) Navigator.pop(context);
                    if (userController.isManager) {
                      context.go(RouteName.managerSettingsPage);
                    } else {
                      userController.changeMenu("Settings");
                    }
                  },
                ),
                _buildNavItem(
                  Icons.help_outline,
                  "Support",
                  activeMenu == "Support",
                  () {
                    if (isMobile) Navigator.pop(context);
                    if (userController.isManager) {
                      context.go(RouteName.managerSupportPage);
                    } else {
                      userController.changeMenu("Support");
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String title,
    bool isActive,
    VoidCallback onTap,
  ) {
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

  Widget _buildTopAppBar(BuildContext context, String username, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 40.0,
        vertical: 16.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: ConstantColor.textPrimaryColor,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Biru Laut",
              style: TextStyle(
                color: ConstantColor.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            // Date
            Text(
              DateFormat('dd MMM yyyy').format(DateTime.now()),
              style: TextStyle(
                color: ConstantColor.textSecondaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const Spacer(),

          // Search Bar
          if (!isMobile) ...[
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
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],

          _buildNotificationIcon(context),
          const SizedBox(width: 24),

          // Logout Button
          if (isMobile)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.red.shade700),
              onPressed: () => _logout(context),
            )
          else
            OutlinedButton(
              onPressed: () => _logout(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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

  Widget _buildNotificationIcon(BuildContext context) {
    final notificationService = Get.find<GlobalNotificationService>();
    return Obx(() {
      final unread = notificationService.unreadCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: ConstantColor.textSecondaryColor,
            ),
            onPressed: () => _showNotificationPopup(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          if (unread > 0)
            Positioned(
              top: -2,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  unread > 99 ? '99+' : unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Future<void> _showNotificationPopup(BuildContext anchorContext) async {
    final notificationService = Get.find<GlobalNotificationService>();
    notificationService.readAll();

    final overlay = Overlay.of(anchorContext).context.findRenderObject();
    final button = anchorContext.findRenderObject();
    if (overlay is! RenderBox || button is! RenderBox) return;

    final screenWidth = overlay.size.width;
    const targetWidth = 380.0;
    const panelHeight = 540.0;
    final panelWidth = screenWidth < targetWidth + 24
        ? (screenWidth - 24).clamp(280.0, targetWidth)
        : targetWidth;

    final buttonOffset = button.localToGlobal(Offset.zero, ancestor: overlay);
    final preferredLeft = buttonOffset.dx + button.size.width - panelWidth;
    final clampedLeft = preferredLeft.clamp(
      12.0,
      screenWidth - panelWidth - 12,
    );
    final top = 50.0;
    final right = screenWidth - clampedLeft - panelWidth;
    final bottom = overlay.size.height - top;

    await showMenu<void>(
      context: anchorContext,
      color: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      constraints: BoxConstraints.tight(Size(panelWidth, panelHeight)),
      position: RelativeRect.fromLTRB(clampedLeft, top, right, bottom),
      items: [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          height: panelHeight,
          child: _buildNotificationPopupContent(
            notificationService: notificationService,
            panelHeight: panelHeight,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationPopupContent({
    required GlobalNotificationService notificationService,
    required double panelHeight,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.white,
        elevation: 18,
        child: SizedBox(
          height: panelHeight,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Notifikasi Terbaru',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: ConstantColor.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: notificationService.readAll,
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          'Tandai semua dibaca',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ConstantColor.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final items = notificationService.notifications;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada notifikasi.',
                        style: TextStyle(
                          color: ConstantColor.textSecondaryColor,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: notificationService.isLoadingMore.value
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final item = items[index];
                      final title = item.title.isNotEmpty
                          ? item.title
                          : (item.message.isNotEmpty
                                ? item.message
                                : 'Notifikasi baru');
                      final detail = item.message.isNotEmpty
                          ? item.message
                          : item.type.toUpperCase();
                      final accentColor = _accentColorForNotificationType(
                        item.type,
                      );

                      return Container(
                        width: double.infinity,
                        height: 115,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(22, 14, 18, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconForNotificationType(item.type),
                                color: accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.15,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                ConstantColor.textPrimaryColor,
                                          ),
                                        ),
                                      ),
                                      if (!item.isRead)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            top: 2,
                                          ),
                                          child: Text(
                                            'BARU',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: accentColor,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    detail,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.35,
                                      color: ConstantColor.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatNotificationTime(item.createdAt),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: ConstantColor.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F6FA),
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Obx(() {
                  final isLoading = notificationService.isLoadingMore.value;
                  return SizedBox(
                    height: 58,
                    child: TextButton(
                      onPressed: !notificationService.hasNextPage || isLoading
                          ? null
                          : () => notificationService.loadMore(),
                      style: TextButton.styleFrom(
                        foregroundColor: ConstantColor.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        isLoading ? 'Memuat...' : 'Lihat Semua Notifikasi',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _accentColorForNotificationType(String type) {
    switch (type.trim().toLowerCase()) {
      case 'upload':
        return const Color(0xFF0D5D8B);
      case 'verifikasi':
        return const Color(0xFF0F8C53);
      case 'reject':
        return const Color(0xFFBB1F1F);
      case 'maintenance':
        return const Color(0xFF7B8794);
      default:
        return ConstantColor.primaryColor;
    }
  }

  String _formatNotificationTime(DateTime? createdAt) {
    if (createdAt == null) return 'Baru saja';

    final now = DateTime.now();
    final localCreatedAt = createdAt.toLocal();
    final diff = now.difference(localCreatedAt);

    if (diff.isNegative) return 'Baru saja';
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

    final day = localCreatedAt.day.toString().padLeft(2, '0');
    final month = localCreatedAt.month.toString().padLeft(2, '0');
    final year = localCreatedAt.year.toString();
    final hour = localCreatedAt.hour.toString().padLeft(2, '0');
    final minute = localCreatedAt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year, $hour:$minute';
  }

  IconData _iconForNotificationType(String type) {
    switch (type.trim().toLowerCase()) {
      case 'upload':
        return Icons.file_upload_outlined;
      case 'verifikasi':
        return Icons.verified_outlined;
      case 'reject':
        return Icons.cancel_outlined;
      case 'maintenance':
        return Icons.handyman_outlined;
      case 'message':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_outlined;
    }
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
    if (!Get.isRegistered<AuthRepository>()) {
      AuthBinding().dependencies();
    }
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
      if (Get.isRegistered<GlobalNotificationService>()) {
        await Get.find<GlobalNotificationService>().stopPolling(
          clearState: true,
        );
      }

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
      if (Get.isRegistered<GlobalNotificationService>()) {
        await Get.find<GlobalNotificationService>().stopPolling(
          clearState: true,
        );
      }
      if (context.mounted) {
        context.go(RouteName.loginScreen);
      }
    }
  }
}
