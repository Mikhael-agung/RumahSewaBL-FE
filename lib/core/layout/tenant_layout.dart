import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/tenant_colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/global_notification_service.dart';
import 'package:go_router/go_router.dart';

class TenantSidebar extends StatelessWidget {
  final String activeLabel;
  final VoidCallback? onDashboardTap;
  final VoidCallback? onPaymentsTap;
  final VoidCallback? onMaintenanceTap;

  const TenantSidebar({
    super.key,
    this.activeLabel = 'Dashboard',
    this.onDashboardTap,
    this.onPaymentsTap,
    this.onMaintenanceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: TenantColors.background,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300.withOpacity(0.6)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biru Laut',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: TenantColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Property Management',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: TenantColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  _SidebarItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    active: activeLabel == 'Dashboard',
                    onTap: onDashboardTap,
                  ),
                  _SidebarItem(
                    icon: Icons.payments_outlined,
                    label: 'Payments',
                    active: activeLabel == 'Payments',
                    onTap: onPaymentsTap,
                  ),
                  _SidebarItem(
                    icon: Icons.handyman_outlined,
                    label: 'Maintenance',
                    active: activeLabel == 'Maintenance',
                    onTap: onMaintenanceTap,
                  ),
                  const Spacer(),
                  const _SidebarItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                  ),
                  const _SidebarItem(
                    icon: Icons.help_outline,
                    label: 'Support',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF005D90).withOpacity(0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          icon,
          size: 20,
          color: active ? TenantColors.primary : TenantColors.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active
                ? TenantColors.primary
                : TenantColors.onSurfaceVariant,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class TenantTopBar extends StatelessWidget {
  final String displayName;
  final double fontScale;
  final VoidCallback? onMenuTap;

  const TenantTopBar({
    super.key,
    required this.displayName,
    this.fontScale = 1.0,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    double _fontScale(_) => fontScale;
    final isNarrow = MediaQuery.of(context).size.width < 900;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TenantColors.background,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300.withOpacity(0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isNarrow
          ? Row(
              children: [
                if (onMenuTap != null)
                  IconButton(
                    onPressed: onMenuTap,
                    icon: const Icon(Icons.menu),
                    color: TenantColors.onSurfaceVariant,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Biru Laut',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16 * _fontScale(context),
                      fontWeight: FontWeight.w800,
                      color: TenantColors.primary,
                    ),
                  ),
                ),
                _buildNotificationButton(context),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.red.shade700),
                  onPressed: () => _logout(context),
                ),
              ],
            )
          : Row(
              children: [
                const Text(
                  "20 Oktober 2023",
                  style: TextStyle(
                    color: ConstantColor.textSecondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
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
                _buildNotificationButton(context),
                const SizedBox(width: 24),
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

  Widget _buildNotificationButton(BuildContext context) {
    final notificationService = Get.find<GlobalNotificationService>();
    return Obx(() {
      final unread = notificationService.unreadCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () => _showNotificationSheet(context),
            icon: const Icon(Icons.notifications_none_outlined),
            color: ConstantColor.textSecondaryColor,
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

  void _showNotificationSheet(BuildContext context) {
    final notificationService = Get.find<GlobalNotificationService>();
    notificationService.markAllAsRead();
    notificationService.refreshNow();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: SizedBox(
            height: 420,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TenantColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Obx(() {
                      final items = notificationService.notifications;
                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            'Belum ada notifikasi.',
                            style: TextStyle(
                              color: TenantColors.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, thickness: 0.5),
                        itemBuilder: (_, index) {
                          final item = items[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            leading: Icon(
                              _iconForNotificationType(item.type),
                              color: TenantColors.primary,
                            ),
                            title: Text(
                              item.title.isNotEmpty
                                  ? item.title
                                  : (item.message.isNotEmpty
                                        ? item.message
                                        : 'Notifikasi baru'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              item.message.isNotEmpty
                                  ? item.message
                                  : item.type.toUpperCase(),
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Text(
                              item.isRead ? 'Read' : 'Unread',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: item.isRead
                                    ? TenantColors.onSurfaceVariant
                                    : Colors.red.shade600,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (!notificationService.hasNextPage) {
                      return const SizedBox.shrink();
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: notificationService.isLoadingMore.value
                            ? null
                            : () => notificationService.loadMore(),
                        child: Text(
                          notificationService.isLoadingMore.value
                              ? 'Memuat...'
                              : 'Muat lebih banyak',
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _iconForNotificationType(String type) {
    switch (type.trim().toLowerCase()) {
      case 'upload':
        return Icons.file_upload_outlined;
      case 'verifikasi':
        return Icons.verified_outlined;
      case 'reject':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (Get.isRegistered<GlobalNotificationService>()) {
      await Get.find<GlobalNotificationService>().stopPolling(clearState: true);
    }
    if (context.mounted) {
      GoRouter.of(context).go(RouteName.loginScreen);
    }
  }
}

class TenantFloatingChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const TenantFloatingChatButton({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TenantColors.primary,
      shape: const CircleBorder(),
      elevation: 10,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.chat, color: Colors.white),
        ),
      ),
    );
  }
}
