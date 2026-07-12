import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/admin_colors.dart';

class AdminMaintenanceContentView extends StatelessWidget {
  const AdminMaintenanceContentView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 650;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.build_outlined, color: AdminColors.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                'Pemeliharaan',
                style: GoogleFonts.manrope(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: AdminColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Halaman ini bisa dipakai untuk melacak tiket perbaikan, jadwal maintenance, dan status pekerjaan.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AdminColors.secondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
