import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/tenant_colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/layout/tenant_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/widgets/tenant_payment_sections.dart';

double _fontScale(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w < 360) return 0.82;
  if (w < 600) return 0.90;
  if (w < 900) return 0.96;
  return 1.0;
}

class TenantDashPage extends StatefulWidget {
  const TenantDashPage({super.key});

  @override
  State<TenantDashPage> createState() => _TenantDashPageState();
}

class _TenantDashPageState extends State<TenantDashPage> {
  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_username') ?? 'User';
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
                'Tombol ini sudah aktif. Silakan lanjutkan ke menu yang dibutuhkan atau hubungi admin.',
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
            body: Stack(
              children: [
                Row(
                  children: [
                    TenantSidebar(
                      activeLabel: 'Dashboard',
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
                                        _DashboardHeader(displayName: displayName),
                                        const SizedBox(height: 24),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            final isWide = constraints.maxWidth >= 1100;

                                            if (isWide) {
                                              return Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 8,
                                                    child: _RoomCard(),
                                                  ),
                                                  const SizedBox(width: 24),
                                                  Expanded(
                                                    flex: 4,
                                                    child: TenantBillingCard(),
                                                  ),
                                                ],
                                              );
                                            }

                                            return Column(
                                              children: [
                                                const _RoomCard(),
                                                const SizedBox(height: 24),
                                                const TenantBillingCard(),
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            final isWide = constraints.maxWidth >= 900;

                                            if (isWide) {
                                              return Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: _SupportCard(
                                                      onPressed: _openMaintenanceSheet,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 24),
                                                  const Expanded(
                                                    flex: 8,
                                                    child: TenantHistoryCard(),
                                                  ),
                                                ],
                                              );
                                            }

                                            return Column(
                                              children: [
                                                _SupportCard(
                                                  onPressed: _openMaintenanceSheet,
                                                ),
                                                const SizedBox(height: 24),
                                                const TenantHistoryCard(),
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        Center(
                                          child: Text(
                                            '© 2023 Rumah Sewa Biru Laut. Coastal Precision.',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 10 * _fontScale(context),
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.1,
                                              color: TenantColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
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
                Positioned(
                  right: 32,
                  bottom: 32,
                  child: _FloatingChatButton(onTap: _openMaintenanceSheet),
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
                activeLabel: 'Dashboard',
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
          body: Stack(
            children: [
              Column(
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
                                _DashboardHeader(displayName: displayName),
                                const SizedBox(height: 16),
                                const _RoomCard(),
                                const SizedBox(height: 16),
                                const TenantBillingCard(),
                                const SizedBox(height: 16),
                                _SupportCard(onPressed: _openMaintenanceSheet),
                                const SizedBox(height: 16),
                                const TenantHistoryCard(),
                                const SizedBox(height: 20),
                                Center(
                                  child: Text(
                                    '© 2023 Rumah Sewa Biru Laut. Coastal Precision.',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10 * _fontScale(context),
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                      color: TenantColors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: _FloatingChatButton(onTap: _openMaintenanceSheet),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String displayName;

  const _DashboardHeader({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 850;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $displayName',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 34 * _fontScale(context),
                        fontWeight: FontWeight.w800,
                        color: TenantColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selamat datang kembali di dashboard hunian Anda.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15 * _fontScale(context),
                        color: TenantColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: TenantColors.primaryContainer.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TenantColors.primary.withOpacity(0.10)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: TenantColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      '20 Oktober 2023',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13 * _fontScale(context),
                        fontWeight: FontWeight.w700,
                        color: TenantColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $displayName',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 30 * _fontScale(context),
                fontWeight: FontWeight.w800,
                color: TenantColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selamat datang kembali di dashboard hunian Anda.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15 * _fontScale(context),
                color: TenantColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: TenantColors.primaryContainer.withOpacity(0.30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TenantColors.primary.withOpacity(0.10)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 18, color: TenantColors.primary),
                  SizedBox(width: 10),
                  Text(
                    '20 Oktober 2023',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TenantColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
                child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: TenantColors.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, rowConstraints) {
                    final narrow = rowConstraints.maxWidth < 420;
                    if (narrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PillLabel(
                            label: 'Kamar Aktif',
                            background: TenantColors.secondaryContainer,
                            textColor: TenantColors.onSecondaryContainer,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'A-204',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 34 * _fontScale(context),
                              height: 1,
                              fontWeight: FontWeight.w800,
                              color: TenantColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gedung Biru Laut Utama',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13 * _fontScale(context),
                              fontWeight: FontWeight.w700,
                              color: TenantColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Harga Sewa Bulanan',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10 * _fontScale(context),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: TenantColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rp 2.500.000',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 22 * _fontScale(context),
                                    fontWeight: FontWeight.w800,
                                    color: TenantColors.onBackground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PillLabel(
                                label: 'Kamar Aktif',
                                background: TenantColors.secondaryContainer,
                                textColor: TenantColors.onSecondaryContainer,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'A-204',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 48 * _fontScale(context),
                                  height: 1,
                                  fontWeight: FontWeight.w800,
                                  color: TenantColors.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gedung Biru Laut Utama',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14 * _fontScale(context),
                                  fontWeight: FontWeight.w700,
                                  color: TenantColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Harga Sewa Bulanan',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10 * _fontScale(context),
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: TenantColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rp 2.500.000',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 28 * _fontScale(context),
                                fontWeight: FontWeight.w800,
                                color: TenantColors.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 700 ? 4 : 2;

                    return Wrap(
                      spacing: 24,
                      runSpacing: 20,
                      children: const [
                        _InfoStat(label: 'Tanggal Mulai', value: '01 Jan 2023'),
                        _InfoStat(label: 'Lama Sewa', value: '12 Bulan'),
                        _InfoStat(label: 'Fasilitas', value: 'AC, Wifi, TV'),
                        _InfoStat(
                          label: 'Status Kontrak',
                          value: 'Aktif',
                          withStatusDot: true,
                        ),
                      ].map((item) {
                        return SizedBox(
                          width: (constraints.maxWidth - ((columns - 1) * 24)) / columns,
                          child: item,
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final VoidCallback onPressed;

  const _SupportCard({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TenantColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.support_agent, color: TenantColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Layanan Perbaikan',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 18 * _fontScale(context),
                    fontWeight: FontWeight.w800,
                    color: TenantColors.onBackground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Ada kendala dengan fasilitas kamar? Laporkan kerusakan untuk segera ditangani tim maintenance kami.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12 * _fontScale(context),
              height: 1.6,
              color: TenantColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: TenantColors.primary,
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text(
              'Ajukan Keluhan',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final String label;
  final String value;
  final bool withStatusDot;

  const _InfoStat({
    required this.label,
    required this.value,
    this.withStatusDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
            style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: TenantColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (withStatusDot)
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: TenantColors.onBackground,
                ),
              ),
            ],
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: TenantColors.onBackground,
            ),
          ),
      ],
    );
  }
}

class _PillLabel extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const _PillLabel({
    required this.label,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: textColor,
        ),
      ),
    );
  }
}

class _FloatingChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FloatingChatButton({required this.onTap});

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
