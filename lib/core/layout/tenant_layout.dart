import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/tenant_colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:go_router/go_router.dart';

// Tenant-specific reusable layout widgets: sidebar, topbar, floating chat button.

class TenantSidebar extends StatelessWidget {
  const TenantSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: TenantColors.background,
        border: Border(right: BorderSide(color: Colors.grey.shade300.withOpacity(0.6))),
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
                children: const [
                  _SidebarItem(icon: Icons.dashboard_outlined, label: 'Dashboard', active: true),
                  _SidebarItem(icon: Icons.payments_outlined, label: 'Payments'),
                  _SidebarItem(icon: Icons.handyman_outlined, label: 'Maintenance'),
                  Spacer(),
                  _SidebarItem(icon: Icons.settings_outlined, label: 'Settings'),
                  _SidebarItem(icon: Icons.help_outline, label: 'Support'),
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

  const _SidebarItem({required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF005D90).withOpacity(0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(icon, size: 20, color: active ? TenantColors.primary : TenantColors.onSurfaceVariant),
        title: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? TenantColors.primary : TenantColors.onSurfaceVariant,
            )),
      ),
    );
  }
}

class TenantTopBar extends StatelessWidget {
  final String displayName;
  final double fontScale;

  const TenantTopBar({super.key, required this.displayName, this.fontScale = 1.0});

  @override
  Widget build(BuildContext context) {
    double _fontScale(_) => fontScale;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
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
      child: Row(
        children: [
          Text(
            'Rumah Sewa Biru Laut',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18 * _fontScale(context),
              fontWeight: FontWeight.w800,
              color: TenantColors.primary,
            ),
          ),
          const Spacer(),
          Container(
            width: 256,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.grey.shade300.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration.collapsed(hintText: ''),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none), color: TenantColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Text('Penyewa Aktif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: TenantColors.onBackground)),
          const SizedBox(width: 12),
          const CircleAvatar(radius: 20, backgroundColor: Color(0xFFD1E4FF), child: Icon(Icons.person, size: 20, color: TenantColors.primary)),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              // ignore: use_build_context_synchronously
              GoRouter.of(context).go(RouteName.loginScreen);
            },
            child: const Text('Logout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: TenantColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
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
