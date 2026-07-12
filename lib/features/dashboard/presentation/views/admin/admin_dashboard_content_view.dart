import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/admin_colors.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/bindings/properties_binding.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/bindings/tenants_binding.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/rooms.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/properties_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/tenants_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/utils/helpers/currency_format.dart';

/// Halaman Dashboard untuk role Admin.
/// Desain mengikuti mockup Stitch (Material 3, AdminColors + Manrope/Inter).
/// Dipecah jadi beberapa method kecil (_buildX) mengikuti pola penulisan
/// [DashboardContentView] punya Manager, biar gampang dirawat.
class AdminDashboardContentView extends StatelessWidget {
  final String username;

  const AdminDashboardContentView({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PropertiesController>()) {
      PropertiesBinding().dependencies();
    }
    if (!Get.isRegistered<TenantsController>()) {
      TenantsBinding().dependencies();
    }
    final propertiesController = Get.find<PropertiesController>();
    final tenantsController = Get.find<TenantsController>();
    final bool isMobile = MediaQuery.of(context).size.width < 650;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroHeader(isMobile),
        SizedBox(height: isMobile ? 24 : 40),
        _buildStatsRow(
          isMobile: isMobile,
          tenantsController: tenantsController,
          propertiesController: propertiesController,
        ),
        SizedBox(height: isMobile ? 24 : 24),
        _buildMainContentSection(context, isMobile, tenantsController),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Hero header
  // ---------------------------------------------------------------------
  Widget _buildHeroHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Halo, $username",
          style: GoogleFonts.manrope(
            fontSize: isMobile ? 26 : 34,
            fontWeight: FontWeight.w800,
            color: AdminColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Ringkasan aktivitas dan status sistem Rumah Sewa Biru Laut.",
          style: GoogleFonts.inter(
            fontSize: isMobile ? 14 : 16,
            color: AdminColors.secondary,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Stats row (4 kartu, data real dari controller)
  // ---------------------------------------------------------------------
  Widget _buildStatsRow({
    required bool isMobile,
    required TenantsController tenantsController,
    required PropertiesController propertiesController,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => Obx(() {
        final isLoading = tenantsController.isLoading.value ||
            propertiesController.isLoading.value;
        final totalActiveTenants = tenantsController.tenants.length;
        final occupiedRooms =
            propertiesController.rooms.where(_isRoomOccupied).length;
        final availableRooms =
            propertiesController.rooms.where(_isRoomAvailable).length;
        final totalBuildings = propertiesController.buildings.length;

        final crossAxisCount = constraints.maxWidth < 600
            ? 1
            : constraints.maxWidth < 1000
                ? 2
                : 4;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.5,
          children: [
            _buildStatCard(
              label: "Total Penyewa Aktif",
              value: isLoading ? "…" : "$totalActiveTenants",
              icon: Icons.groups_outlined,
              accent: AdminColors.primary,
              accentBg: AdminColors.primaryFixed,
            ),
            _buildStatCard(
              label: "Kamar Terisi",
              value: isLoading ? "…" : "$occupiedRooms",
              icon: Icons.meeting_room_outlined,
              accent: AdminColors.primary,
              accentBg: AdminColors.primaryFixed,
            ),
            _buildStatCard(
              label: "Kamar Kosong",
              value: isLoading ? "…" : "$availableRooms",
              icon: Icons.hotel_outlined,
              accent: AdminColors.error,
              accentBg: AdminColors.errorContainer,
            ),
            _buildStatCard(
              label: "Total Gedung",
              value: isLoading ? "…" : "$totalBuildings",
              icon: Icons.apartment_outlined,
              accent: AdminColors.primary,
              accentBg: AdminColors.primaryFixed,
            ),
          ],
        );
      }),
    );
  }

  bool _isRoomOccupied(Room room) {
    final normalized = room.roomStatus.toString().trim().toLowerCase();
    return normalized == 'occupied' ||
        normalized == 'terisi' ||
        normalized == 'booked';
  }

  bool _isRoomAvailable(Room room) {
    final normalized = room.roomStatus.toString().trim().toLowerCase();
    return normalized == 'available' ||
        normalized == 'kosong' ||
        normalized == 'vacant';
  }

  /// Stat card: rounded-xl, border tipis, blur circle dekoratif di pojok,
  /// icon badge kanan atas, angka besar di bawah — persis token mockup.
  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
    required Color accentBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.primaryFixed.withValues(alpha: 0.4),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -16,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: accentBg.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.secondary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Main content: 2 kolom — Penyewa Perlu Ditinjau | Ringkasan Sistem
  // ---------------------------------------------------------------------
  Widget _buildMainContentSection(
    BuildContext context,
    bool isMobile,
    TenantsController tenantsController,
  ) {
    final left = _buildTenantsReviewCard(tenantsController);
    final right = _buildSystemSummaryCard();

    if (isMobile) {
      return Column(
        children: [left, const SizedBox(height: 20), right],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 1, child: left),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: right),
        ],
      ),
    );
  }

  /// Kartu kiri "Penyewa Perlu Ditinjau".
  /// TODO(backend): sekarang cuma nampilin daftar penyewa asli
  /// (nama dari [TenantsController]) tanpa status tunggakan real,
  /// karena entity Tenant belum punya field kamar/jumlah/status bayar.
  /// Ganti ke data asli begitu endpoint tunggakan/verifikasi ada
  /// (lihat pola [PaymentsBloc] untuk status "Perlu Verifikasi").
  Widget _buildTenantsReviewCard(TenantsController tenantsController) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AdminColors.surfaceBright,
              border: Border(
                bottom: BorderSide(
                  color: AdminColors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Penyewa Perlu Ditinjau",
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Lihat Semua",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward,
                        size: 14, color: AdminColors.primary),
                  ],
                ),
              ],
            ),
          ),
          Obx(() {
            if (tenantsController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (tenantsController.tenants.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Belum ada data penyewa.",
                  style: GoogleFonts.inter(color: AdminColors.secondary),
                ),
              );
            }
            final preview = tenantsController.tenants.take(4).toList();
            return Column(
              children: [
                for (int i = 0; i < preview.length; i++)
                  _buildTenantReviewItem(
                    name: preview[i].fullName,
                    subtitle: preview[i].tenantCode,
                    isLast: i == preview.length - 1,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTenantReviewItem({
    required String name,
    required String subtitle,
    required bool isLast,
  }) {
    final initials = name.trim().isEmpty
        ? "?"
        : name.trim().split(RegExp(r"\s+")).take(2).map((e) => e[0]).join().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AdminColors.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AdminColors.primaryFixed,
            child: Text(
              initials,
              style: GoogleFonts.manrope(
                color: AdminColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AdminColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu kanan "Ringkasan Sistem".
  /// TODO(backend): angka pendapatan & bar chart masih placeholder statis
  /// (belum ada endpoint agregasi pendapatan bulanan). Pola ini sama kayak
  /// "Monitoring Tunggakan" milik Manager yang juga masih hardcode.
  Widget _buildSystemSummaryCard() {
    const monthlyData = <_MonthBar>[
      _MonthBar("Feb", 0.40),
      _MonthBar("Mar", 0.55),
      _MonthBar("Apr", 0.45),
      _MonthBar("Mei", 0.70),
      _MonthBar("Jun", 0.60),
      _MonthBar("Jul", 0.90, isCurrent: true),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AdminColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ringkasan Sistem",
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AdminColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Menampilkan data finansial admin",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AdminColors.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Pendapatan Bulan Ini",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AdminColors.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            children: [
              Text(
                currencyIdr.format(45600000),
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.onSurface,
                ),
              ),
              Text(
                "↑ 12% dari bulan lalu",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bar in monthlyData)
                  Expanded(child: _buildBarColumn(bar)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: AdminColors.outlineVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.pending_actions_outlined,
            "5 pembayaran menunggu verifikasi",
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.event_available_outlined,
            "2 sewa akan berakhir bulan ini",
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(_MonthBar bar) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: bar.heightFactor,
                widthFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: bar.isCurrent
                        ? AdminColors.primaryContainer
                        : AdminColors.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            bar.label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: bar.isCurrent ? FontWeight.w800 : FontWeight.w600,
              color: bar.isCurrent
                  ? AdminColors.onSurface
                  : AdminColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AdminColors.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthBar {
  final String label;
  final double heightFactor;
  final bool isCurrent;

  const _MonthBar(this.label, this.heightFactor, {this.isCurrent = false});
}