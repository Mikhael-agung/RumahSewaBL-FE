import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/utils/helpers/currency_format.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: Column(
                  children: [
                    _TopNavbar(
                      onLoginTap: () => context.go(RouteName.loginScreen),
                    ),
                    const SizedBox(height: 18),
                    _HeroSection(
                      onLoginTap: () => context.go(RouteName.loginScreen),
                    ),
                    const SizedBox(height: 26),
                    const _CuratedExperienceSection(),
                    const SizedBox(height: 26),
                    const _AvailableUnitsSection(),
                    const SizedBox(height: 26),
                    const _StrategicLocationSection(),
                    const SizedBox(height: 26),
                    const _ContactSection(),
                    const SizedBox(height: 20),
                    const _LandingFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNavbar extends StatelessWidget {
  final VoidCallback onLoginTap;

  const _TopNavbar({required this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Rumah Sewa Biru Laut',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ConstantColor.primaryColor,
              ),
            ),
          ),
          FilledButton(
            onPressed: onLoginTap,
            style: FilledButton.styleFrom(
              backgroundColor: ConstantColor.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final VoidCallback onLoginTap;

  const _HeroSection({required this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroText(onLoginTap),
                const SizedBox(height: 16),
                _heroImage(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _heroText(onLoginTap)),
              const SizedBox(width: 24),
              Expanded(child: _heroImage()),
            ],
          );
        },
      ),
    );
  }

  Widget _heroText(VoidCallback onLoginTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Now Opening in Jakarta',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Your Sanctuary\nBy the Sea',
          style: TextStyle(
            fontSize: 50,
            height: 1.05,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Experience a harmonious blend of modern living and natural tranquility, with premium rental spaces built for comfort and productivity.',
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: ConstantColor.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onLoginTap,
          style: FilledButton.styleFrom(
            backgroundColor: ConstantColor.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          child: const Text(
            'Login',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _heroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          'https://images.unsplash.com/photo-1616137466211-f939a420be84?auto=format&fit=crop&w=1400&q=80',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _CuratedExperienceSection extends StatelessWidget {
  const _CuratedExperienceSection();

  @override
  Widget build(BuildContext context) {
    const features = [
      (
        Icons.wifi_rounded,
        'High-Speed WiFi',
        'Koneksi stabil untuk kerja remote.',
      ),
      (Icons.ac_unit_rounded, 'Full AC', 'Kontrol suhu nyaman setiap saat.'),
      (
        Icons.local_laundry_service_rounded,
        'Laundry',
        'Layanan laundry tersedia setiap hari.',
      ),
      (
        Icons.cleaning_services_rounded,
        'Housekeeping',
        'Pembersihan berkala untuk setiap unit.',
      ),
    ];

    return _CardSection(
      title: 'Curated Living Experience',
      subtitle:
          'Fasilitas premium yang dirancang untuk kenyamanan dan produktivitas.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          if (isMobile) {
            return Column(
              children: [
                for (var i = 0; i < features.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == features.length - 1 ? 0 : 12,
                    ),
                    child: _FeatureCard(
                      icon: features[i].$1,
                      title: features[i].$2,
                      description: features[i].$3,
                    ),
                  ),
              ],
            );
          }

          return Row(
            children: [
              for (var i = 0; i < features.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == features.length - 1 ? 0 : 12,
                    ),
                    child: _FeatureCard(
                      icon: features[i].$1,
                      title: features[i].$2,
                      description: features[i].$3,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ConstantColor.primaryColor, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ConstantColor.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableUnitsSection extends StatelessWidget {
  const _AvailableUnitsSection();

  static const units = [
    (
      'Azure Standard',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?auto=format&fit=crop&w=1200&q=80',
      24,
      'Queen Bed',
      2000000,
    ),
    (
      'Breeze Studio',
      'https://images.unsplash.com/photo-1566665797739-1674de7a421a?auto=format&fit=crop&w=1200&q=80',
      32,
      'King Bed',
      2800000,
    ),
    (
      'Marine Loft',
      'https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?auto=format&fit=crop&w=1200&q=80',
      45,
      'King Bed',
      3500000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: 'Available Units',
      subtitle: 'Pilih unit yang paling sesuai dengan kebutuhan Anda.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          if (isMobile) {
            return Column(
              children: [
                for (var i = 0; i < units.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == units.length - 1 ? 0 : 12,
                    ),
                    child: _UnitCard(
                      title: units[i].$1,
                      imageUrl: units[i].$2,
                      area: units[i].$3,
                      bedType: units[i].$4,
                      price: currencyIdr.format(units[i].$5),
                    ),
                  ),
              ],
            );
          }

          return Row(
            children: [
              for (var i = 0; i < units.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == units.length - 1 ? 0 : 12,
                    ),
                    child: _UnitCard(
                      title: units[i].$1,
                      imageUrl: units[i].$2,
                      area: units[i].$3,
                      bedType: units[i].$4,
                      price: currencyIdr.format(units[i].$5),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final int area;
  final String bedType;
  final String price;

  const _UnitCard({
    required this.title,
    required this.imageUrl,
    required this.area,
    required this.bedType,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$area m² • $bedType',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mulai $price / bulan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ConstantColor.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StrategicLocationSection extends StatelessWidget {
  const _StrategicLocationSection();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: 'Strategic Location',
      subtitle:
          'Lokasi dekat pusat kota dengan akses cepat ke fasilitas utama.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _LocationInfoRow(
                icon: Icons.route_rounded,
                text: '5 mins walk ke MRT Setiabudi',
              ),
              SizedBox(height: 10),
              _LocationInfoRow(
                icon: Icons.business_rounded,
                text: '10 mins drive ke pusat bisnis',
              ),
              SizedBox(height: 10),
              _LocationInfoRow(
                icon: Icons.local_hospital_rounded,
                text: '8 mins ke RS Internasional',
              ),
            ],
          );

          const map = ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1569336415962-a4bd9f69c07b?auto=format&fit=crop&w=1400&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          );

          if (isMobile) {
            return Column(children: [info, const SizedBox(height: 14), map]);
          }

          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 16),
              const Expanded(child: map),
            ],
          );
        },
      ),
    );
  }
}

class _LocationInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _LocationInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ConstantColor.primaryColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ConstantColor.primaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Ready to find your home?',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Hubungi tim kami untuk jadwal survei dan informasi unit terbaru.',
                style: TextStyle(fontSize: 15, color: Color(0xFFDCEFFF)),
              ),
            ],
          );

          final form = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Nama Lengkap',
                    fillColor: const Color(0xFFF3F4F6),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                    fillColor: const Color(0xFFF3F4F6),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: ConstantColor.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Send Inquiry',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          );

          if (isMobile) {
            return Column(children: [left, const SizedBox(height: 16), form]);
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: left),
              const SizedBox(width: 18),
              Expanded(flex: 2, child: form),
            ],
          );
        },
      ),
    );
  }
}

class _LandingFooter extends StatelessWidget {
  const _LandingFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'Rumah Sewa Biru Laut\n© 2024 Rumah Sewa Biru Laut.',
              style: TextStyle(
                fontSize: 12,
                color: ConstantColor.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            'Privacy Policy    Terms    Contact',
            style: TextStyle(
              fontSize: 12,
              color: ConstantColor.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CardSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: ConstantColor.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
