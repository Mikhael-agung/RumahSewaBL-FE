import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/tenant_colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/layout/tenant_layout.dart';
// If you want exact Manrope/Inter fonts, add them to assets/fonts and
// register in pubspec.yaml. For now we use fontFamily strings so the app
// can build without the google_fonts package (avoids web const-eval issues).

double _fontScale(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w < 360) return 0.82;
  if (w < 600) return 0.90;
  if (w < 900) return 0.96;
  return 1.0;
}

class TenantDashPage extends StatelessWidget {
  const TenantDashPage({super.key});

  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_username') ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUsername(),
      builder: (context, snapshot) {
        final username = snapshot.data ?? 'User';
        final displayName = username == 'User' ? 'Budi Santoso' : username;

        return Scaffold(
          backgroundColor: TenantColors.background,
          body: Stack(
            children: [
              Row(
                children: [
                  const TenantSidebar(),
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
                                                SizedBox(width: 24),
                                                Expanded(
                                                  flex: 4,
                                                  child: _BillingCard(),
                                                ),
                                              ],
                                            );
                                          }

                                          return const Column(
                                            children: [
                                              _RoomCard(),
                                              SizedBox(height: 24),
                                              _BillingCard(),
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
                                              children: const [
                                                Expanded(
                                                  flex: 4,
                                                  child: _SupportCard(),
                                                ),
                                                SizedBox(width: 24),
                                                Expanded(
                                                  flex: 8,
                                                  child: _HistoryCard(),
                                                ),
                                              ],
                                            );
                                          }

                                          return const Column(
                                            children: [
                                              _SupportCard(),
                                              SizedBox(height: 24),
                                              _HistoryCard(),
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
                child: _FloatingChatButton(onTap: () {}),
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
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: TenantColors.onBackground,
                fontFamily: 'Serif',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selamat datang kembali di dashboard hunian Anda.',
              style: TextStyle(
                fontSize: 15,
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

class _BillingCard extends StatelessWidget {
  const _BillingCard();

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                  Text(
                'Tagihan Bulan Ini',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18 * _fontScale(context),
                  fontWeight: FontWeight.w800,
                  color: TenantColors.onBackground,
                ),
              ),
              Icon(Icons.receipt_long, color: TenantColors.primary),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
              color: TenantColors.tertiaryFixed.withOpacity(0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TenantColors.tertiaryFixed),
            ),
                  child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFF8A3E00)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Peringatan Deadline',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11 * _fontScale(context),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: TenantColors.onTertiaryFixedVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Segera lakukan pembayaran sebelum tanggal 20 Oktober untuk menghindari denda.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12 * _fontScale(context),
                          height: 1.5,
                          color: TenantColors.onTertiaryFixedVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bulan Berjalan',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: TenantColors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Oktober 2023',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: TenantColors.onBackground,
                    ),
                  ),
                ],
              ),
              _PillLabel(
                label: 'Belum Bayar',
                background: TenantColors.error,
                textColor: TenantColors.onError,
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Bukti Bayar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TenantColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Format: PNG, JPG, PDF (Max 5MB)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                        color: TenantColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

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
            onPressed: () {},
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard();

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
          Text(
            'Riwayat Pembayaran',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18 * _fontScale(context),
              fontWeight: FontWeight.w800,
              color: TenantColors.onBackground,
            ),
          ),
          const SizedBox(height: 18),
          _HistoryItem(
            month: 'September 2023',
            invoice: 'INV/202309/012',
            amount: 'Rp 2.500.000',
          ),
          const SizedBox(height: 12),
          _HistoryItem(
            month: 'Agustus 2023',
            invoice: 'INV/202308/045',
            amount: 'Rp 2.500.000',
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: TenantColors.primary,
              side: BorderSide(color: TenantColors.primary.withOpacity(0.2)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: const SizedBox(
              width: double.infinity,
              child: Center(child: Text('Lihat Semua Riwayat')),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String month;
  final String invoice;
  final String amount;

  const _HistoryItem({
    required this.month,
    required this.invoice,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TenantColors.background.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
              decoration: BoxDecoration(
              color: TenantColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: TenantColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14 * _fontScale(context),
                    fontWeight: FontWeight.w800,
                    color: TenantColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invoice,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                        color: TenantColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'Rp 2.500.000',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: TenantColors.onBackground,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Terverifikasi',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: TenantColors.primary,
                ),
              ),
            ],
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
