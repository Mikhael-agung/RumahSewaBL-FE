import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/tenant_colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/layout/tenant_layout.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/widgets/tenant_payment_sections.dart';

class TenantPaymentsPage extends StatefulWidget {
  const TenantPaymentsPage({super.key});

  @override
  State<TenantPaymentsPage> createState() => _TenantPaymentsPageState();
}

class _TenantPaymentsPageState extends State<TenantPaymentsPage> {
  int _historyRefreshToken = 0;

  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_username') ?? 'User';
  }

  void _refreshHistory() {
    setState(() {
      _historyRefreshToken++;
    });
  }

  Future<void> _openMaintenanceSheet() async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ajukan Keluhan Maintenance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: TenantColors.onBackground),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan lanjutkan ke dashboard untuk melihat semua fitur lain.',
                style: TextStyle(fontSize: 13, color: TenantColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUsername(),
      builder: (context, snapshot) {
        final username = snapshot.data ?? 'User';
        final displayName = username == 'User' ? 'Budi Santoso' : username;

        final isNarrowScreen = MediaQuery.of(context).size.width < 900;
        final scaffoldKey = GlobalKey<ScaffoldState>();

        if (!isNarrowScreen) {
          return Scaffold(
            backgroundColor: TenantColors.background,
            body: Row(
              children: [
                TenantSidebar(
                  activeLabel: 'Payments',
                  onDashboardTap: () => context.go(RouteName.tenantDashPage),
                  onPaymentsTap: () => context.go(RouteName.tenantPaymentsPage),
                  onMaintenanceTap: _openMaintenanceSheet,
                ),
                Expanded(
                  child: Column(
                    children: [
                      TenantTopBar(displayName: displayName),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1280),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pembayaran',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: TenantColors.onBackground,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Kelola dan pantau pembayaran sewa Anda',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: TenantColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    TenantBillingCard(onUploaded: _refreshHistory),
                                    const SizedBox(height: 24),
                                    TenantPaymentsHistoryTableCard(key: ValueKey(_historyRefreshToken)),
                                  ],
                                ),
                              ),
                            ),
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

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: TenantColors.background,
          drawer: Drawer(
            child: SafeArea(
              child: TenantSidebar(
                activeLabel: 'Payments',
                onDashboardTap: () {
                  Navigator.of(context).pop();
                  context.go(RouteName.tenantDashPage);
                },
                onPaymentsTap: () {
                  Navigator.of(context).pop();
                  context.go(RouteName.tenantPaymentsPage);
                },
                onMaintenanceTap: () {
                  Navigator.of(context).pop();
                  _openMaintenanceSheet();
                },
              ),
            ),
          ),
          body: Column(
            children: [
              TenantTopBar(displayName: displayName, onMenuTap: () => scaffoldKey.currentState?.openDrawer()),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pembayaran',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: TenantColors.onBackground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Kelola dan pantau pembayaran sewa Anda',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: TenantColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TenantBillingCard(onUploaded: _refreshHistory),
                            const SizedBox(height: 16),
                            TenantPaymentsHistoryTableCard(key: ValueKey(_historyRefreshToken)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
