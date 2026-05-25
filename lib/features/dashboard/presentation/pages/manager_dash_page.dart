import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/layout/base_dashboard_layout.dart';
import 'package:rumah_sewa_biru_laut_fe/core/controllers/user_controller.dart';

class ManagerDashPage extends StatelessWidget {
  final String activeMenu;

  const ManagerDashPage({
    super.key,
    required this.activeMenu,
  });

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return BaseDashboardLayout(
      activeMenu: activeMenu,
      child: Obx(() {
        final username = userController.username.value.isNotEmpty 
            ? userController.username.value 
            : "Rina Hartati";

        switch (activeMenu) {
          case 'Dashboard':
            return _buildDashboardContent(context, username);
          case 'Properties':
            return _buildPropertiesContent(context);
          case 'Tenants':
            return _buildTenantsContent(context);
          case 'Payments':
            return _buildPaymentsContent(context);
          case 'Maintenance':
            return _buildMaintenanceContent(context);
          case 'Settings':
            return _buildSettingsContent(context);
          case 'Support':
            return _buildSupportContent(context);
          default:
            return _buildDashboardContent(context, username);
        }
      }),
    );
  }

  // ==========================================
  // 1. MAIN DASHBOARD CONTENT
  // ==========================================
  Widget _buildDashboardContent(BuildContext context, String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Header
        Text(
          "Halo, $username",
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: ConstantColor.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Selamat datang di dashboard manajemen Biru Laut.",
          style: TextStyle(
            fontSize: 16,
            color: ConstantColor.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),

        // Metrics Grid (4 items)
        LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = (constraints.maxWidth - 72) / 4;
            if (constraints.maxWidth < 900) {
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.4,
                children: _getMetricCards(),
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _getMetricCards().map((card) => SizedBox(width: cardWidth, child: card)).toList(),
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

  List<Widget> _getMetricCards() {
    return [
      _buildMetricCard(
        "Total Penyewa Aktif",
        "24",
        Icons.person_outline_rounded,
        const Color(0xFF0077B6),
        const Color(0xFFE0EFFF),
      ),
      _buildMetricCard(
        "Total Kamar Terisi",
        "24",
        Icons.door_back_door_outlined,
        const Color(0xFF0077B6),
        const Color(0xFFE0EFFF),
      ),
      _buildMetricCard(
        "Kamar Kosong",
        "6",
        Icons.hotel_outlined,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
      ),
      _buildMetricCard(
        "Total Gedung",
        "3",
        Icons.apartment_outlined,
        const Color(0xFF0077B6),
        const Color(0xFFE0EFFF),
      ),
    ];
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color iconColor, Color iconBgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon in soft circle background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          // Label uppercase
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
          // Value text
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

  // 1A. MONITORING TUNGGAKAN TABLE
  Widget _buildTunggakanCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28.0),
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
          
          // Arrearages List/Table representation
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.8),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Header
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
              
              // Row 1: Budi Santoso
              _buildTunggakanRow("Budi Santoso", "BS", "A-204", "1 BULAN", false),
              // Row 2: Siti Rahayu
              _buildTunggakanRow("Siti Rahayu", "SR", "B-101", "2 BULAN", true),
              // Row 3: Andi Wijaya
              _buildTunggakanRow("Andi Wijaya", "AW", "A-301", "1 BULAN", false),
              // Row 4: Dewi Kusuma
              _buildTunggakanRow("Dewi Kusuma", "DK", "C-205", "2 BULAN", true),
            ],
          ),
          const SizedBox(height: 24),
          
          // View all arrearages button
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

  TableRow _buildTunggakanRow(String name, String initials, String room, String period, bool isSevere) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      children: [
        // Name with avatar initials
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
        // Room
        Text(room, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        // Arrearage pill
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
        // Remind Button
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

  // 1B. INCOMING PAYMENTS LIST
  Widget _buildPembayaranCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28.0),
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
          
          // Payments List
          _buildPaymentItem("Rini Astuti", "UNIT B-202 • RP 2.5JT", "VERIFIKASI", true),
          _buildPaymentItem("Hadi Pranoto", "UNIT A-105 • RP 2.5JT", "VERIFIKASI", true),
          _buildPaymentItem("Maya Sari", "UNIT C-301 • RP 2.0JT", "SELESAI", false),
          
          const SizedBox(height: 24),
          
          // View all payments button
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
          // Payment icon
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
          
          // Details
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
          
          // Status Pill
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

  // ==========================================
  // 2. PROPERTIES VIEW PLACEHOLDER
  // ==========================================
  Widget _buildPropertiesContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kelola Properti & Gedung",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor),
        ),
        const SizedBox(height: 8),
        const Text(
          "Kelola unit hunian, ketersediaan kamar, dan tarif sewa.",
          style: TextStyle(fontSize: 16, color: ConstantColor.textSecondaryColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 0.9,
          children: [
            _buildPropertyCard("Gedung A - Blue Coast", "12 Kamar Terisi • 2 Kosong", "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&w=400&q=80"),
            _buildPropertyCard("Gedung B - Horizon", "8 Kamar Terisi • 2 Kosong", "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=400&q=80"),
            _buildPropertyCard("Gedung C - Ocean View", "4 Kamar Terisi • 2 Kosong", "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?auto=format&fit=crop&w=400&q=80"),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyCard(String title, String subtitle, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0077B6)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("LIHAT DETAIL UNIT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0077B6))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. TENANTS VIEW PLACEHOLDER
  // ==========================================
  Widget _buildTenantsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Daftar Penyewa Aktif",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor),
        ),
        const SizedBox(height: 8),
        const Text(
          "Manajemen data profil penyewa, durasi sewa, dan riwayat kontak.",
          style: TextStyle(fontSize: 16, color: ConstantColor.textSecondaryColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Daftar Anggota Hunian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor)),
                  Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF0077B6)),
                ],
              ),
              const SizedBox(height: 24),
              _buildTenantListTile("Budi Santoso", "Kamar A-204 • Mulai Jan 2023", "0812-3456-7890", true),
              _buildTenantListTile("Siti Rahayu", "Kamar B-101 • Mulai Mar 2023", "0821-9876-5432", true),
              _buildTenantListTile("Andi Wijaya", "Kamar A-301 • Mulai Jun 2023", "0877-2244-6688", true),
              _buildTenantListTile("Dewi Kusuma", "Kamar C-205 • Mulai Sep 2023", "0896-1133-5577", true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTenantListTile(String name, String desc, String phone, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE0EFFF),
            child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0077B6))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(phone, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(width: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(8)),
            child: const Text("AKTIF", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. PAYMENTS VIEW PLACEHOLDER
  // ==========================================
  Widget _buildPaymentsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Laporan Keuangan & Pembayaran",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor),
        ),
        const SizedBox(height: 8),
        const Text(
          "Lihat mutasi saldo, pencatatan transaksi masuk, dan verifikasi kuitansi sewa.",
          style: TextStyle(fontSize: 16, color: ConstantColor.textSecondaryColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Riwayat Transaksi Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor)),
              const SizedBox(height: 24),
              _buildTransactionItem("Transfer Bank BNI", "Dari: Budi Santoso • 18 Okt 2023", "+ Rp 2.500.000", true),
              _buildTransactionItem("Transfer Bank Mandiri", "Dari: Maya Sari • 15 Okt 2023", "+ Rp 2.000.000", true),
              _buildTransactionItem("Beli Peralatan Kebersihan", "Operasional Gedung • 12 Okt 2023", "- Rp 350.000", false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String title, String desc, String amount, bool isIncome) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isIncome ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isIncome ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? const Color(0xFF059669) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. MAINTENANCE VIEW PLACEHOLDER
  // ==========================================
  Widget _buildMaintenanceContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kelola Tiket Perbaikan",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor),
        ),
        const SizedBox(height: 8),
        const Text(
          "Pantau dan tindaklanjuti laporan kendala fasilitas hunian dari penyewa.",
          style: TextStyle(fontSize: 16, color: ConstantColor.textSecondaryColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Tiket Kendala Fasilitas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor)),
              const SizedBox(height: 24),
              _buildMaintenanceTicket("AC Bocor & Kurang Dingin", "Kamar A-204 • Budi Santoso", "TINGGI", "DIKERJAKAN"),
              _buildMaintenanceTicket("Kran Air Kamar Mandi Bocor", "Kamar B-101 • Siti Rahayu", "SEDANG", "MENUNGGU"),
              _buildMaintenanceTicket("Lampu Kamar Redup / Mati", "Kamar C-205 • Dewi Kusuma", "RENDAH", "SELESAI"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceTicket(String title, String info, String priority, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFEF3C7),
                child: Icon(Icons.build_outlined, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(info, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Priority Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priority == "TINGGI" ? const Color(0xFFFEE2E2) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: priority == "TINGGI" ? const Color(0xFFDC2626) : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == "SELESAI" ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: status == "SELESAI" ? const Color(0xFF059669) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. SETTINGS VIEW PLACEHOLDER
  // ==========================================
  Widget _buildSettingsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pengaturan Sistem",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor),
        ),
        const SizedBox(height: 8),
        const Text(
          "Konfigurasi profil pengelolaan, notifikasi tagihan otomatis, dan keamanan akun.",
          style: TextStyle(fontSize: 16, color: ConstantColor.textSecondaryColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Opsi Konfigurasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor)),
              const SizedBox(height: 24),
              _buildSettingTile("Kirim Notifikasi Tagihan Otomatis", "Kirim pengingat WhatsApp ke penyewa setiap tanggal 25.", true),
              _buildSettingTile("Verifikasi Pembayaran Otomatis", "Gunakan sistem pintar untuk memverifikasi struk transfer.", false),
              _buildSettingTile("Mode Pemeliharaan Server", "Matikan sinkronisasi database untuk backup mingguan.", false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(String title, String desc, bool isEnabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (val) {},
            activeColor: const Color(0xFF0077B6),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 7. SUPPORT VIEW PLACEHOLDER
  // ==========================================
  Widget _buildSupportContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dukungan & Pusat Bantuan",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor),
        ),
        const SizedBox(height: 8),
        const Text(
          "Butuh bantuan? Tim pengembang dan admin sistem siap membantu Anda menyelesaikan masalah.",
          style: TextStyle(fontSize: 16, color: ConstantColor.textSecondaryColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Kontak Tim Pengembang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor)),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: _buildSupportCard("Dukungan Teknis Dev", "dev@rumahsewabirulaut.com", Icons.email_outlined),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildSupportCard("Hotline Sistem", "+62 811-2233-4455", Icons.phone_in_talk_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportCard(String title, String contact, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0077B6), size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text(contact, style: const TextStyle(fontSize: 14, color: Color(0xFF0077B6), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
