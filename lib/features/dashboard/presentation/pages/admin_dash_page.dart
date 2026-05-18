import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/layout/base_dashboard_layout.dart';

class AdminDashPage extends StatelessWidget {
  const AdminDashPage({super.key});

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

        return BaseDashboardLayout(
          title: "Dashboard Admin",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $username",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: ConstantColor.textPrimaryColor,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Selamat datang di dashboard manajemen Biru Laut.",
                style: TextStyle(
                  fontSize: 16,
                  color: ConstantColor.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                height: 400,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Center(
                  child: Text(
                    "Area Konten Dashboard Admin (Komponen Belum Dibuat)",
                    style: TextStyle(color: Colors.grey),
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
