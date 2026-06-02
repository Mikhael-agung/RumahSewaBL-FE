import 'package:flutter/material.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';

class TenantsContentView extends StatelessWidget {
  const TenantsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Daftar Penyewa Aktif",
          style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          "Manajemen data profil penyewa, durasi sewa, dan riwayat kontak.",
          style: TextStyle(fontSize: isMobile ? 14 : 16, color: ConstantColor.textSecondaryColor, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: isMobile ? 24 : 32),
        
        Container(
          padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Daftar Anggota Hunian", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor)),
                  IconButton(
                    icon: const Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF0077B6)),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTenantListTile(context, "Budi Santoso", "Kamar A-204 • Mulai Jan 2023", "0812-3456-7890", true),
              _buildTenantListTile(context, "Siti Rahayu", "Kamar B-101 • Mulai Mar 2023", "0821-9876-5432", true),
              _buildTenantListTile(context, "Andi Wijaya", "Kamar A-301 • Mulai Jun 2023", "0877-2244-6688", true),
              _buildTenantListTile(context, "Dewi Kusuma", "Kamar C-205 • Mulai Sep 2023", "0896-1133-5577", true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTenantListTile(BuildContext context, String name, String desc, String phone, bool isActive) {
    final bool isNarrow = MediaQuery.of(context).size.width < 650;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE0EFFF),
                      child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0077B6))),
                    ),
                    const SizedBox(width: 12),
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
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(8)),
                      child: const Text("AKTIF", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "No. Telepon:",
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    Text(
                      phone,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ],
            )
          : Row(
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
}
