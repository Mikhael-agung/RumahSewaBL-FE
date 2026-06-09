import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/properties_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/building.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/rooms.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/bindings/properties_binding.dart';

class PropertiesContentView extends StatelessWidget {
  const PropertiesContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    // Initialize Clean Architecture dependencies
    PropertiesBinding().dependencies();
    final controller = Get.find<PropertiesController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Properties",
          style: TextStyle(
            fontSize: isMobile ? 24 : 32, 
            fontWeight: FontWeight.bold, 
            color: ConstantColor.textPrimaryColor
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Kelola gedung dan kamar sewa",
          style: TextStyle(
            fontSize: isMobile ? 14 : 16, 
            color: ConstantColor.textSecondaryColor, 
            fontWeight: FontWeight.w500
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),

        Obx(() {
          // Register GetX observers for list changes so that Metric Cards rebuild correctly
          final _ = controller.buildings.length;
          final _2 = controller.rooms.length;

          if (controller.isLoading.value) {
            return Container(
              height: 350,
              alignment: Alignment.center,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ConstantColor.primaryColor),
                    strokeWidth: 3.5,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Memuat data properti...",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ConstantColor.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Metric Cards Row
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return GridView.count(
                      crossAxisCount: 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3.2,
                      children: _getMetricCards(context, controller),
                    );
                  } else if (constraints.maxWidth < 950) {
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.6,
                      children: _getMetricCards(context, controller),
                    );
                  } else {
                    double cardWidth = (constraints.maxWidth - 72) / 4;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _getMetricCards(context, controller).map((card) => SizedBox(width: cardWidth, child: card)).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 32),

              // 2. Daftar Gedung Card
              _buildGedungCard(context, controller),
              const SizedBox(height: 32),

              // 3. Daftar Kamar Card
              _buildKamarCard(context, controller),
            ],
          );
        }),
      ],
    );
  }

  // ==========================================
  // METRICS BUILDER
  // ==========================================
  List<Widget> _getMetricCards(BuildContext context, PropertiesController controller) {
    final bool buildingsLoading = controller.isBuildingsLoading.value;
    final bool generalLoading = controller.isLoading.value;

    return [
      _buildMetricCard(
        context,
        "Total Gedung",
        buildingsLoading ? "..." : "${controller.buildings.length}",
        Icons.apartment_outlined,
        const Color(0xFF0077B6),
        const Color(0xFFE0EFFF),
      ),
      _buildMetricCard(
        context,
        "Total Kamar",
        generalLoading ? "..." : "${controller.rooms.length * 6}",
        Icons.door_back_door_outlined,
        const Color(0xFF0077B6),
        const Color(0xFFE0EFFF),
      ),
      _buildMetricCard(
        context,
        "Kamar Terisi",
        generalLoading ? "..." : "${controller.rooms.where((r) => r['isTerisi'] == true).length}",
        Icons.check_circle_outline_rounded,
        const Color(0xFF0077B6),
        const Color(0xFFE0EFFF),
      ),
      _buildMetricCard(
        context,
        "Kamar Kosong",
        generalLoading ? "..." : "${controller.rooms.where((r) => r['isTerisi'] == false).length}",
        Icons.hotel_outlined,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
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

  // ==========================================
  // DAFTAR GEDUNG CARD
  // ==========================================
  Widget _buildGedungCard(BuildContext context, PropertiesController controller) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daftar Gedung",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddBuildingModal(context, controller),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text(
                  "Tambah Gedung",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005D90),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Buildings Table wrapped in scroll view to never overflow on mobile
          Obx(() {
            final bool isLoading = controller.isBuildingsLoading.value;
            
            return isMobile
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 500,
                      ),
                      child: isLoading ? _buildGedungShimmer() : _buildGedungTable(context, controller),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: isLoading ? _buildGedungShimmer() : _buildGedungTable(context, controller),
                  );
          }),
        ],
      ),
    );
  }

  Widget _buildGedungShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF1F5F9),
      highlightColor: const Color(0xFFE2E8F0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.0), // No
          1: FlexColumnWidth(4.5), // Nama Gedung
          2: FlexColumnWidth(3.0), // Jumlah Kamar
          3: FlexColumnWidth(2.5), // Aksi
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
                child: Text("NO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text("NAMA GEDUNG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text("JUMLAH KAMAR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text("AKSI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              ),
            ],
          ),
          ...List.generate(3, (index) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    height: 14,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 32.0),
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 14,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 14,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGedungTable(BuildContext context, PropertiesController controller) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.0), // No
        1: FlexColumnWidth(4.5), // Nama Gedung
        2: FlexColumnWidth(3.0), // Jumlah Kamar
        3: FlexColumnWidth(2.5), // Aksi
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Table Header
        const TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("NO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("NAMA GEDUNG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("JUMLAH KAMAR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("AKSI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
            ),
          ],
        ),
        
        // Table Rows from controller data
        ...controller.buildings.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final building = entry.value;
          
          final nameLower = building.buildingName.toLowerCase();
          final count = controller.rooms.where((room) {
            final roomGedung = (room['gedung'] ?? '').toString().toLowerCase();
            return roomGedung.isNotEmpty && nameLower.contains(roomGedung);
          }).length;
          final roomsCountStr = "$count Kamar";

          return _buildGedungRow(
            context,
            controller,
            index.toString(),
            building,
            roomsCountStr,
          );
        }).toList(),
      ],
    );
  }

  TableRow _buildGedungRow(BuildContext context, PropertiesController controller, String no, Building building, String roomsCount) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(no, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
        ),
        Text(building.buildingName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        Text(roomsCount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        Row(
          children: [
            TextButton(
              onPressed: () => _showEditBuildingModal(context, controller, building),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 30)),
              child: const Text("Edit", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0077B6))),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => _showDeleteBuildingConfirmation(context, controller, building),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 30)),
              child: const Text("Hapus", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // DAFTAR KAMAR CARD
  // ==========================================
  Widget _buildKamarCard(BuildContext context, PropertiesController controller) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
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
          // Header Row with title, filter dropdown, and Tamah button
          Row(
            children: [
              const Text(
                "Daftar Kamar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(width: 12),
              // Dropdown Filter Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text(
                      "Semua Gedung",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF475569)),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddRoomModal(context, controller),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text(
                  "Tambah Kamar",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005D90),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Room table wrapped in horizontal scroll view on mobile
          Obx(() {
            final bool isLoading = controller.isRoomsLoading.value;
            
            return isMobile
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 650,
                      ),
                      child: isLoading ? _buildKamarShimmer() : _buildKamarTable(context, controller),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: isLoading ? _buildKamarShimmer() : _buildKamarTable(context, controller),
                  );
          }),
          const SizedBox(height: 24),

          // Pagination Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                "Menampilkan ${controller.roomss.length > 5 ? 5 : controller.roomss.length} dari ${controller.roomss.length} kamar",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              )),
              // Pagination Controls
              Row(
                children: [
                  _buildPaginationButton("<", isSelected: false),
                  const SizedBox(width: 8),
                  _buildPaginationButton("1", isSelected: true),
                  const SizedBox(width: 8),
                  _buildPaginationButton("2", isSelected: false),
                  const SizedBox(width: 8),
                  _buildPaginationButton("3", isSelected: false),
                  const SizedBox(width: 8),
                  _buildPaginationButton(">", isSelected: false),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKamarShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF1F5F9),
      highlightColor: const Color(0xFFE2E8F0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.0), // Kode Kamar
          1: FlexColumnWidth(2.5), // Gedung
          2: FlexColumnWidth(3.0), // Harga Sewa
          3: FlexColumnWidth(2.5), // Status
          4: FlexColumnWidth(2.0), // Aksi
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
                child: Text("KODE KAMAR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text("GEDUNG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text("HARGA SEWA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text("AKSI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
              ),
            ],
          ),
          ...List.generate(3, (index) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Container(
                    height: 14,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    height: 14,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    height: 14,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 32.0),
                  child: Container(
                    height: 18,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 14,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 14,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildKamarTable(BuildContext context, PropertiesController controller) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.0), // Kode Kamar
        1: FlexColumnWidth(2.5), // Gedung
        2: FlexColumnWidth(3.0), // Harga Sewa
        3: FlexColumnWidth(2.5), // Status
        4: FlexColumnWidth(2.0), // Aksi
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Table Header
        const TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.5)),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("KODE KAMAR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("GEDUNG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("HARGA SEWA", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("STATUS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text("AKSI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
            ),
          ],
        ),
        
        // Table Rows from controller data
        ...controller.roomss.map((room) {
          final building = controller.buildings.firstWhereOrNull((b) => b.id == room.buildingId);
          final buildingName = building?.buildingName ?? (room.building?.buildingName ?? '-');

          return _buildKamarRow(
            context,
            controller,
            room,
            buildingName,
          );
        }).toList(),
      ],
    );
  }

  TableRow _buildKamarRow(BuildContext context, PropertiesController controller, Room room, String buildingName) {
    final String displayStatus = room.roomStatus == "occupied" 
        ? "Terisi" 
        : room.roomStatus == "maintenance" 
            ? "Perawatan" 
            : "Kosong";
    final Color statusPillColor = room.roomStatus == "occupied" 
        ? const Color(0xFF0077B6) 
        : room.roomStatus == "maintenance" 
            ? Colors.orange 
            : const Color(0xFFE2E8F0);
    final Color statusTextColor = room.roomStatus == "occupied" || room.roomStatus == "maintenance"
        ? Colors.white 
        : const Color(0xFF64748B);

    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(room.roomCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ),
        Text(buildingName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        Text(_formatRupiah(room.monthlyPrice), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        // Status Pill
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusPillColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                     fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => _showEditRoomModal(context, controller, room),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 30)),
              child: const Text("Edit", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0077B6))),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => _showDeleteRoomConfirmation(context, controller, room),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 30)),
              child: const Text("Hapus", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaginationButton(String label, {required bool isSelected}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF005D90) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  void _showAddRoomModal(BuildContext context, PropertiesController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return _AddRoomDialog(controller: controller);
      },
    );
  }

  String _formatRupiah(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }

  void _showAddBuildingModal(BuildContext context, PropertiesController controller) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return _AddBuildingDialog(controller: controller);
      },
    );
  }

  void _showEditBuildingModal(BuildContext context, PropertiesController controller, Building building) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return _EditBuildingDialog(controller: controller, building: building);
      },
    );
  }

  void _showDeleteBuildingConfirmation(BuildContext context, PropertiesController controller, Building building) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return _DeleteBuildingConfirmationDialog(controller: controller, building: building);
      },
    );
  }
}

class _AddBuildingDialog extends StatefulWidget {
  final PropertiesController controller;
  const _AddBuildingDialog({required this.controller});

  @override
  State<_AddBuildingDialog> createState() => _AddBuildingDialogState();
}

class _AddBuildingDialogState extends State<_AddBuildingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 24,
      backgroundColor: Colors.white,
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tambah Gedung",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: ConstantColor.textSecondaryColor, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kode Gedung Label
              const Text(
                "Kode Gedung",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _buildInputDecoration("Contoh: GDG-A"),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Kode gedung wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Nama Gedung Label
              const Text(
                "Nama Gedung",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _buildInputDecoration("Contoh: Gedung A"),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Nama gedung wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Alamat Gedung Label
              const Text(
                "Alamat Gedung",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _buildInputDecoration("Contoh: Jl. Contoh No. 1, Surabaya"),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Alamat gedung wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Deskripsi Label
              const Text(
                "Deskripsi",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 2,
                decoration: _buildInputDecoration("Contoh: Gedung utama lantai 3"),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      final success = await widget.controller.addBuilding(
                        code: _codeController.text.trim(),
                        name: _nameController.text.trim(),
                        address: _addressController.text.trim(),
                        description: _descController.text.trim(),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? "Gedung berhasil ditambahkan!" : "Gedung berhasil ditambahkan secara lokal!"),
                            backgroundColor: ConstantColor.primaryColor,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005D90),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    "Batal",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF005D90)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0077B6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}

class _AddRoomDialog extends StatefulWidget {
  final PropertiesController controller;
  const _AddRoomDialog({required this.controller});

  @override
  State<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<_AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _hargaController = TextEditingController();
  final _notesController = TextEditingController();
  Building? _selectedBuilding;
  String _selectedStatus = 'available';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller.buildings.isNotEmpty) {
      _selectedBuilding = widget.controller.buildings.first;
    }
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _hargaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0077B6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 24,
      backgroundColor: Colors.white,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tambah Kamar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: ConstantColor.textSecondaryColor, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pilih Gedung Label
              const Text(
                "Pilih Gedung *",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              // Dropdown Gedung
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<Building>(
                    value: _selectedBuilding,
                    isExpanded: true,
                    decoration: const InputDecoration(border: InputBorder.none),
                    icon: const Icon(Icons.keyboard_arrow_down, color: ConstantColor.textSecondaryColor),
                    hint: const Text("Pilih Gedung"),
                    items: widget.controller.buildings.map((building) {
                      return DropdownMenuItem<Building>(
                        value: building,
                        child: Text(building.buildingName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBuilding = val;
                      });
                    },
                    validator: (val) => val == null ? "Wajib memilih gedung" : null,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kode Kamar Label
              const Text(
                "Kode Kamar",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              // Input Kode Kamar
              TextFormField(
                controller: _kodeController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _buildInputDecoration("Contoh: A-101"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Kode kamar wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Harga Sewa Label
              const Text(
                "Harga Sewa (Bulan)",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              // Input Harga Sewa
              TextFormField(
                controller: _hargaController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration("Contoh: 2000000"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Harga sewa wajib diisi";
                  }
                  if (int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) == null) {
                    return "Harga sewa harus berupa angka";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status Kamar Label
              const Text(
                "Status Kamar",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              // Dropdown Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: ConstantColor.textSecondaryColor),
                    items: const [
                      DropdownMenuItem(value: 'available', child: Text('Kosong')),
                      DropdownMenuItem(value: 'occupied', child: Text('Terisi')),
                      DropdownMenuItem(value: 'maintenance', child: Text('Perawatan')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      }
                    },
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Catatan/Notes Label
              const Text(
                "Catatan (Opsional)",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 2,
                decoration: _buildInputDecoration("Masukkan catatan kamar jika ada"),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      final price = int.tryParse(_hargaController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                      final success = await widget.controller.addRoom(
                        buildingId: _selectedBuilding!.id,
                        roomCode: _kodeController.text.trim(),
                        monthlyPrice: price,
                        roomStatus: _selectedStatus,
                        notes: _notesController.text.trim(),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? "Kamar berhasil ditambahkan!" : "Kamar gagal ditambahkan!"),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005D90),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    "Batal",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF005D90)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditRoomDialog extends StatefulWidget {
  final PropertiesController controller;
  final Room room;
  const _EditRoomDialog({required this.controller, required this.room});

  @override
  State<_EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<_EditRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kodeController;
  late final TextEditingController _hargaController;
  late final TextEditingController _notesController;
  Building? _selectedBuilding;
  late String _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _kodeController = TextEditingController(text: widget.room.roomCode);
    _hargaController = TextEditingController(text: widget.room.monthlyPrice.toString());
    _notesController = TextEditingController(text: widget.room.notes);
    _selectedStatus = widget.room.roomStatus;

    if (widget.controller.buildings.isNotEmpty) {
      _selectedBuilding = widget.controller.buildings.firstWhereOrNull((b) => b.id == widget.room.buildingId) ?? widget.controller.buildings.first;
    }
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _hargaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF005D90), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 24,
      backgroundColor: Colors.white,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Edit Kamar",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: ConstantColor.textSecondaryColor, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pilih Gedung Label
              const Text(
                "Pilih Gedung *",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              // Dropdown Gedung
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<Building>(
                    value: _selectedBuilding,
                    isExpanded: true,
                    decoration: const InputDecoration(border: InputBorder.none),
                    icon: const Icon(Icons.keyboard_arrow_down, color: ConstantColor.textSecondaryColor),
                    hint: const Text("Pilih Gedung"),
                    items: widget.controller.buildings.map((building) {
                      return DropdownMenuItem<Building>(
                        value: building,
                        child: Text(building.buildingName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedBuilding = val;
                      });
                    },
                    validator: (val) => val == null ? "Wajib memilih gedung" : null,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kode Kamar Label
              const Text(
                "Kode Kamar",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              // Input Kode Kamar
              TextFormField(
                controller: _kodeController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _buildInputDecoration("Contoh: A-101"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Kode kamar wajib diisi";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Harga Sewa Label
              const Text(
                "Harga Sewa (Bulan)",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              // Input Harga Sewa
              TextFormField(
                controller: _hargaController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration("Contoh: 2000000"),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "Harga sewa wajib diisi";
                  }
                  if (int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) == null) {
                    return "Harga sewa harus berupa angka";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Status Kamar Label
              const Text(
                "Status Kamar",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              // Dropdown Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: ConstantColor.textSecondaryColor),
                    items: const [
                      DropdownMenuItem(value: 'available', child: Text('Kosong')),
                      DropdownMenuItem(value: 'occupied', child: Text('Terisi')),
                      DropdownMenuItem(value: 'maintenance', child: Text('Perawatan')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      }
                    },
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Catatan/Notes Label
              const Text(
                "Catatan (Opsional)",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 2,
                decoration: _buildInputDecoration("Masukkan catatan kamar jika ada"),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      final price = int.tryParse(_hargaController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                      final success = await widget.controller.updateRoom(
                        id: widget.room.id,
                        buildingId: _selectedBuilding!.id,
                        roomCode: _kodeController.text.trim(),
                        monthlyPrice: price,
                        roomStatus: _selectedStatus,
                        notes: _notesController.text.trim(),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? "Kamar berhasil diperbarui!" : "Kamar gagal diperbarui!"),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005D90),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    "Batal",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF005D90)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteRoomConfirmationDialog extends StatefulWidget {
  final PropertiesController controller;
  final Room room;
  const _DeleteRoomConfirmationDialog({required this.controller, required this.room});

  @override
  State<_DeleteRoomConfirmationDialog> createState() => _DeleteRoomConfirmationDialogState();
}

class _DeleteRoomConfirmationDialogState extends State<_DeleteRoomConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 24,
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              "Hapus Kamar?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ConstantColor.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              "Apakah Anda yakin ingin menghapus kamar \"${widget.room.roomCode}\"? Tindakan ini tidak dapat dibatalkan.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: ConstantColor.textSecondaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final success = await widget.controller.deleteRoom(widget.room.id);
                  setState(() {
                    _isLoading = false;
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? "Kamar berhasil dihapus!" : "Kamar gagal dihapus!"),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Hapus",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showEditRoomModal(BuildContext context, PropertiesController controller, Room room) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) {
      return _EditRoomDialog(controller: controller, room: room);
    },
  );
}

void _showDeleteRoomConfirmation(BuildContext context, PropertiesController controller, Room room) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) {
      return _DeleteRoomConfirmationDialog(controller: controller, room: room);
    },
  );
}

class _EditBuildingDialog extends StatefulWidget {
  final PropertiesController controller;
  final Building building;
  const _EditBuildingDialog({required this.controller, required this.building});

  @override
  State<_EditBuildingDialog> createState() => _EditBuildingDialogState();
}

class _EditBuildingDialogState extends State<_EditBuildingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _descController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.building.buildingCode);
    _nameController = TextEditingController(text: widget.building.buildingName);
    _addressController = TextEditingController(text: widget.building.buildingAddress);
    _descController = TextEditingController(text: widget.building.description);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF005D90), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 24,
      backgroundColor: Colors.white,
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Edit Gedung",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ConstantColor.textPrimaryColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: ConstantColor.textSecondaryColor, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kode Gedung Label
              const Text(
                "Kode Gedung",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _codeController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _buildInputDecoration("Contoh: GDG-A"),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Kode gedung wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Nama Gedung Label
              const Text(
                "Nama Gedung",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _buildInputDecoration("Contoh: Gedung A"),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Nama gedung wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Alamat Gedung Label
              const Text(
                "Alamat Gedung",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                decoration: _buildInputDecoration("Contoh: Jl. Contoh No. 1, Surabaya"),
                validator: (val) => (val == null || val.trim().isEmpty) ? "Alamat gedung wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Deskripsi Label
              const Text(
                "Deskripsi",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                maxLines: 2,
                decoration: _buildInputDecoration("Contoh: Gedung utama lantai 3"),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });
                      final success = await widget.controller.updateBuilding(
                        id: widget.building.id,
                        code: _codeController.text.trim(),
                        name: _nameController.text.trim(),
                        address: _addressController.text.trim(),
                        description: _descController.text.trim(),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? "Gedung berhasil diperbarui!" : "Gedung berhasil diperbarui secara lokal!"),
                            backgroundColor: ConstantColor.primaryColor,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005D90),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Simpan",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    "Batal",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF005D90)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteBuildingConfirmationDialog extends StatefulWidget {
  final PropertiesController controller;
  final Building building;
  const _DeleteBuildingConfirmationDialog({required this.controller, required this.building});

  @override
  State<_DeleteBuildingConfirmationDialog> createState() => _DeleteBuildingConfirmationDialogState();
}

class _DeleteBuildingConfirmationDialogState extends State<_DeleteBuildingConfirmationDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 24,
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              "Hapus Gedung?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ConstantColor.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              "Apakah Anda yakin ingin menghapus gedung \"${widget.building.buildingName}\"? Tindakan ini tidak dapat dibatalkan.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: ConstantColor.textSecondaryColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final success = await widget.controller.deleteBuilding(widget.building.id);
                  setState(() {
                    _isLoading = false;
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? "Gedung berhasil dihapus!" : "Gedung gagal dihapus!"),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Hapus",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
