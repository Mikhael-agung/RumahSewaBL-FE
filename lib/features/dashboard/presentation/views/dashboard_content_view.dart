import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';

class DashboardContentView extends StatelessWidget {
  final String username;

  const DashboardContentView({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Header
        Text(
          "Halo, $username",
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: ConstantColor.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Selamat datang di dashboard manajemen Biru Laut.",
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: ConstantColor.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),

        // Metrics Grid (4 items)
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Mobile layout: 1 column of horizontal metric cards
              return GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3.2,
                children: _getMetricCards(context),
              );
            } else if (constraints.maxWidth < 900) {
              // Tablet layout: 2 columns
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.4,
                children: _getMetricCards(context),
              );
            } else {
              // Desktop layout
              double cardWidth = (constraints.maxWidth - 72) / 4;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _getMetricCards(context).map((card) => SizedBox(width: cardWidth, child: card)).toList(),
              );
            }
          },
        ),
        const SizedBox(height: 32),

        // Row of Table and List
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1100) {
              return Column(
                children: [
                  _buildTunggakanCard(context),
                  const SizedBox(height: 32),
                  _buildPembayaranCard(context),
                ],
              );
            } else {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildTunggakanCard(context)),
                  const SizedBox(width: 32),
                  Expanded(flex: 2, child: _buildPembayaranCard(context)),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  List<Widget> _getMetricCards(BuildContext context) {
    return [
      _buildMetricCard(
        context,
        "Total Penyewa Aktif",
        "24",
        Icons.person_outline_rounded,
        const Color(0xFF0077B6),
        const Color(0xFFE0EFFF),
      ),
      _buildMetricCard(
        context,
        "Total Kamar Terisi",
        "24",
        Icons.door_back_door_outlined,
        const Color(0xFF0077B6),
        const Color(0xFFE0EFFF),
      ),
      _buildMetricCard(
        context,
        "Kamar Kosong",
        "6",
        Icons.hotel_outlined,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
      ),
      _buildMetricCard(
        context,
        "Total Gedung",
        "3",
        Icons.apartment_outlined,
        const Color(0xFF0077B6),
        const Color(0xFFE0EFFF),
      ),
    ];
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon, Color iconColor, Color iconBgColor) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 12 : 24, 
        horizontal: isMobile ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: isMobile 
        ? Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: ConstantColor.textSecondaryColor,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ConstantColor.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textSecondaryColor,
                  letterSpacing: 0.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTunggakanCard(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 650;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Monitoring Tunggakan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Bulan Oktober 2023",
                    style: TextStyle(
                      fontSize: 12,
                      color: ConstantColor.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.filter_list_outlined,
                  size: 18,
                  color: ConstantColor.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          if (isMobile) ...[
            _buildTunggakanItemMobile("Budi Santoso", "BS", "A-204", "1 BULAN", false),
            _buildTunggakanItemMobile("Siti Rahayu", "SR", "B-101", "2 BULAN", true),
            _buildTunggakanItemMobile("Andi Wijaya", "AW", "A-301", "1 BULAN", false),
            _buildTunggakanItemMobile("Dewi Kusuma", "DK", "C-205", "2 BULAN", true),
          ] else ...[
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.8),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text("NAMA PENYEWA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text("KAMAR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text("TUNGGAKAN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text("AKSI", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)), textAlign: TextAlign.center),
                    ),
                  ],
                ),
                _buildTunggakanRow("Budi Santoso", "BS", "A-204", "1 BULAN", false),
                _buildTunggakanRow("Siti Rahayu", "SR", "B-101", "2 BULAN", true),
                _buildTunggakanRow("Andi Wijaya", "AW", "A-301", "1 BULAN", false),
                _buildTunggakanRow("Dewi Kusuma", "DK", "C-205", "2 BULAN", true),
              ],
            ),
          ],
          const SizedBox(height: 24),
          
          Center(
            child: TextButton(
              onPressed: () {
                Get.snackbar("Informasi", "Membuka semua data tunggakan...", snackPosition: SnackPosition.BOTTOM);
              },
              child: const Text(
                "LIHAT SEMUA TUNGGAKAN",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0077B6),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTunggakanItemMobile(String name, String initials, String room, String period, bool isSevere) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF1F5F9),
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Kamar: $room",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSevere ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSevere ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton(
              onPressed: () {
                Get.snackbar(
                  "Sukses",
                  "Pesan pengingat pembayaran dikirim ke $name!",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFD1FAE5),
                  colorText: const Color(0xFF065F46),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0077B6)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_outlined, size: 16, color: Color(0xFF0077B6)),
                  SizedBox(width: 8),
                  Text(
                    "KIRIM PENGINGAT",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0077B6)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTunggakanRow(String name, String initials, String room, String period, bool isSevere) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF1F5F9),
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Text(room, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isSevere ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                period,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSevere ? const Color(0xFFDC2626) : const Color(0xFFD97706),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Center(
            child: SizedBox(
              height: 32,
              child: OutlinedButton(
                onPressed: () {
                  Get.snackbar(
                    "Sukses",
                    "Pesan pengingat pembayaran dikirim ke $name!",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFD1FAE5),
                    colorText: const Color(0xFF065F46),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0077B6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  "INGATKAN",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0077B6)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPembayaranCard(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pembayaran Masuk",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ConstantColor.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Update hari ini",
            style: TextStyle(
              fontSize: 12,
              color: ConstantColor.textSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildPaymentItem("Rini Astuti", "UNIT B-202 • RP 2.5JT", "VERIFIKASI", true),
          _buildPaymentItem("Hadi Pranoto", "UNIT A-105 • RP 2.5JT", "VERIFIKASI", true),
          _buildPaymentItem("Maya Sari", "UNIT C-301 • RP 2.0JT", "SELESAI", false),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar("Informasi", "Membuka seluruh riwayat pembayaran...", snackPosition: SnackPosition.BOTTOM);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ConstantColor.buttonColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                "LIHAT SEMUA",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(String name, String details, String status, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPending ? const Color(0xFFE0EFFF) : const Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending ? Icons.receipt_long_outlined : Icons.check_circle_outline_rounded,
              color: isPending ? const Color(0xFF0077B6) : const Color(0xFF059669),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isPending ? const Color(0xFFD97706) : const Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
