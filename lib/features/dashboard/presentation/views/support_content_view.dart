import 'package:flutter/material.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';

class SupportContentView extends StatelessWidget {
  const SupportContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dukungan & Pusat Bantuan",
          style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          "Butuh bantuan? Tim pengembang dan admin sistem siap membantu Anda menyelesaikan masalah.",
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
              const Text("Kontak Tim Pengembang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ConstantColor.textPrimaryColor)),
              const SizedBox(height: 24),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        _buildSupportCard("Dukungan Teknis Dev", "dev@rumahsewabirulaut.com", Icons.email_outlined),
                        const SizedBox(height: 16),
                        _buildSupportCard("Hotline Sistem", "+62 811-2233-4455", Icons.phone_in_talk_outlined),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(
                          child: _buildSupportCard("Dukungan Teknis Dev", "dev@rumahsewabirulaut.com", Icons.email_outlined),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildSupportCard("Hotline Sistem", "+62 811-2233-4455", Icons.phone_in_talk_outlined),
                        ),
                      ],
                    );
                  }
                },
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
