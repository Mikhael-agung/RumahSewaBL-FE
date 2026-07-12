import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/admin_colors.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/bindings/activity_log_binding.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/activity_log.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/activity_log_controller.dart';

/// Halaman Activity Log untuk role Admin.
/// Desain mengikuti mockup Stitch (Material 3, AdminColors + Manrope/Inter).
/// Sumber data: GET /api/activity-logs (admin-only, lihat handoff BE) —
/// tidak ada data dummy, semua dari [ActivityLogController].
///
/// Catatan: BE cuma paginate (10/halaman) tanpa endpoint search/filter/stats
/// terpisah, jadi search & filter di sini cuma jalan di halaman yang lagi
/// ke-load (bukan across seluruh dataset). Lihat komentar di
/// [ActivityLogController] untuk detail.
class ActivityLogContentView extends StatelessWidget {
  const ActivityLogContentView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ActivityLogController>()) {
      ActivityLogBinding().dependencies();
    }
    final controller = Get.find<ActivityLogController>();
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroHeader(isMobile),
        SizedBox(height: isMobile ? 24 : 40),
        _buildStatsRow(isMobile: isMobile, controller: controller),
        SizedBox(height: isMobile ? 20 : 24),
        _buildMainSection(context, isMobile, controller),
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
          "Activity Log",
          style: GoogleFonts.manrope(
            fontSize: isMobile ? 26 : 34,
            fontWeight: FontWeight.w800,
            color: AdminColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Riwayat aktivitas seluruh pengguna sistem",
          style: GoogleFonts.inter(
            fontSize: isMobile ? 14 : 16,
            color: AdminColors.secondary,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Stats row — semuanya dihitung dari data real (bukan angka statis)
  // ---------------------------------------------------------------------
  Widget _buildStatsRow({
    required bool isMobile,
    required ActivityLogController controller,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => Obx(() {
        final isLoading = controller.isLoading.value;
        final total = controller.total.value;
        final onPage = controller.logs.length;
        final sensitiveOnPage = controller.logs
            .where((l) => _sensitiveTypes.contains(l.activityType))
            .length;

        final crossAxisCount = constraints.maxWidth < 600
            ? 1
            : constraints.maxWidth < 1000
                ? 2
                : 3;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: crossAxisCount == 1 ? 2.6 : 1.7,
          children: [
            _buildStatCard(
              label: "Total Aktivitas Tercatat",
              value: isLoading ? "…" : "$total",
              sub: "Seluruh riwayat sistem",
              icon: Icons.insights_outlined,
              accent: AdminColors.primary,
              accentBg: AdminColors.primaryFixed,
            ),
            _buildStatCard(
              label: "Aktivitas Halaman Ini",
              value: isLoading ? "…" : "$onPage",
              sub: "Halaman ${controller.currentPage.value} dari ${controller.lastPage.value}",
              icon: Icons.description_outlined,
              accent: AdminColors.primary,
              accentBg: AdminColors.primaryFixed,
            ),
            _buildStatCard(
              label: "Aksi Sensitif (Halaman Ini)",
              value: isLoading ? "…" : "$sensitiveOnPage",
              sub: "Hapus data, reset password, dll",
              icon: Icons.warning_amber_rounded,
              accent: AdminColors.error,
              accentBg: AdminColors.errorContainer,
            ),
          ],
        );
      }),
    );
  }

  static const _sensitiveTypes = {
    'delete_tenant',
    'delete_building',
    'delete_room',
    'delete_rental',
    'toggle_user_active',
    'reset_user_password',
    'create_user',
  };

  Widget _buildStatCard({
    required String label,
    required String value,
    required String sub,
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
        border: Border.all(color: AdminColors.primaryFixed.withValues(alpha: 0.4)),
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
              const SizedBox(height: 14),
              Text(
                value,
                style: GoogleFonts.manrope(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: GoogleFonts.inter(fontSize: 11, color: AdminColors.secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Main section: search + filter, table, pagination
  // ---------------------------------------------------------------------
  Widget _buildMainSection(
    BuildContext context,
    bool isMobile,
    ActivityLogController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(isMobile, controller),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (controller.filteredLogs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    controller.logs.isEmpty
                        ? "Belum ada aktivitas tercatat."
                        : "Tidak ada aktivitas yang cocok dengan pencarian/filter.",
                    style: GoogleFonts.inter(color: AdminColors.secondary),
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: isMobile ? 780 : double.infinity),
                child: _buildTable(context, controller.filteredLogs),
              ),
            );
          }),
          _buildPaginationFooter(controller),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isMobile, ActivityLogController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceBright,
        border: Border(
          bottom: BorderSide(color: AdminColors.outlineVariant.withValues(alpha: 0.25)),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: isMobile ? double.infinity : 340,
            child: TextField(
              onChanged: controller.search,
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                hintText: "Cari user, jenis, atau deskripsi...",
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AdminColors.secondary),
                prefixIcon: Icon(Icons.search, size: 18, color: AdminColors.secondary),
                filled: true,
                fillColor: AdminColors.primaryFixed.withValues(alpha: 0.12),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Obx(
            () => _buildFilterDropdown(controller.activeFilter.value, controller.setFilter),
          ),
          Obx(
            () => IconButton(
              tooltip: "Muat ulang",
              onPressed: controller.isLoading.value ? null : controller.refresh,
              icon: Icon(Icons.refresh, size: 20, color: AdminColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    ActivityLogFilter active,
    void Function(ActivityLogFilter) onChanged,
  ) {
    const labels = {
      ActivityLogFilter.all: "Semua Aktivitas",
      ActivityLogFilter.auth: "Login & Akun",
      ActivityLogFilter.payment: "Pembayaran",
      ActivityLogFilter.system: "Sistem",
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ActivityLogFilter>(
          value: active,
          isDense: true,
          icon: Icon(Icons.expand_more, size: 18, color: AdminColors.secondary),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AdminColors.onSurface,
          ),
          items: labels.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<ActivityLog> items) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.6), // Waktu
        1: FlexColumnWidth(2.2), // User
        2: FlexColumnWidth(1.6), // Jenis
        3: FlexColumnWidth(3.0), // Deskripsi
        4: FlexColumnWidth(1.4), // IP
        5: FlexColumnWidth(0.8), // Aksi
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: AdminColors.surfaceContainer.withValues(alpha: 0.5)),
          children: [
            _buildHeaderCell("WAKTU"),
            _buildHeaderCell("USER"),
            _buildHeaderCell("JENIS AKTIVITAS"),
            _buildHeaderCell("DESKRIPSI"),
            _buildHeaderCell("IP ADDRESS"),
            _buildHeaderCell(""),
          ],
        ),
        ...items.map((logItem) => _buildRow(context, logItem)),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AdminColors.secondary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  TableRow _buildRow(BuildContext context, ActivityLog logItem) {
    final badge = _badgeFor(logItem.activityType);
    final username = logItem.user?.username ?? "User #${logItem.userId ?? '-'}";
    final initials = username.trim().isEmpty
        ? "?"
        : username.trim().substring(0, 1).toUpperCase();

    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AdminColors.outlineVariant.withValues(alpha: 0.15)),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDateTime(logItem.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.onSurface,
                ),
              ),
              Text(
                _relativeTime(logItem.createdAt),
                style: GoogleFonts.inter(fontSize: 11, color: AdminColors.secondary),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AdminColors.primaryFixed,
                child: Text(
                  initials,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badge.bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              logItem.activityType.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badge.fg,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            logItem.activityDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 12, color: AdminColors.onSurfaceVariant),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            logItem.ipAddress ?? "-",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AdminColors.secondary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: IconButton(
            tooltip: "Detail",
            icon: Icon(Icons.visibility_outlined, size: 18, color: AdminColors.secondary),
            onPressed: () => _showDetailDialog(context, logItem),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }

  ({Color bg, Color fg}) _badgeFor(String type) {
    if (type == 'login' || type == 'logout' || type == 'change_password') {
      return (bg: AdminColors.primaryFixed, fg: AdminColors.primaryContainer);
    }
    if (type.startsWith('delete_') ||
        type == 'toggle_user_active' ||
        type == 'reset_user_password') {
      return (bg: AdminColors.errorContainer, fg: AdminColors.error);
    }
    if (type.startsWith('verify_') || type == 'create_user') {
      return (bg: AdminColors.successContainer, fg: AdminColors.success);
    }
    if (type.startsWith('create_') || type.startsWith('update_')) {
      return (bg: AdminColors.warningContainer, fg: AdminColors.warning);
    }
    return (
      bg: AdminColors.surfaceContainerHigh,
      fg: AdminColors.onSurfaceVariant,
    );
  }

  void _showDetailDialog(BuildContext context, ActivityLog logItem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Detail Aktivitas",
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow("User", logItem.user?.username ?? "-"),
              _detailRow("Jenis", logItem.activityType),
              _detailRow("Deskripsi", logItem.activityDescription),
              _detailRow("IP Address", logItem.ipAddress ?? "-"),
              _detailRow("User Agent", logItem.userAgent ?? "-"),
              _detailRow("Waktu", _formatDateTime(logItem.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AdminColors.secondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(fontSize: 13, color: AdminColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(ActivityLogController controller) {
    return Obx(() {
      final current = controller.currentPage.value;
      final last = controller.lastPage.value;
      final total = controller.total.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AdminColors.outlineVariant.withValues(alpha: 0.2)),
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              "Halaman $current dari $last • $total aktivitas total",
              style: GoogleFonts.inter(fontSize: 12, color: AdminColors.secondary),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: current > 1 ? () => controller.goToPage(current - 1) : null,
                  icon: const Icon(Icons.chevron_left, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AdminColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "$current",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.onPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: current < last ? () => controller.goToPage(current + 1) : null,
                  icon: const Icon(Icons.chevron_right, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return "-";
    return DateFormat('dd MMM yyyy, HH:mm').format(dt.toLocal());
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return "";
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} menit yang lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam yang lalu";
    return "${diff.inDays} hari yang lalu";
  }
}