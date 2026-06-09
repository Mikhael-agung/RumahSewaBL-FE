import 'package:flutter/material.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';

class SettingsContentView extends StatelessWidget {
  const SettingsContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pengaturan Sistem",
          style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          "Konfigurasi profil pengelolaan, notifikasi tagihan otomatis, dan keamanan akun.",
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
}
