import 'package:flutter/material.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';

class PaymentsContentView extends StatelessWidget {
  const PaymentsContentView({super.key});

  static const List<_PaymentEntry> _entries = [
    _PaymentEntry(
      no: '01',
      initials: 'BP',
      tenantName: 'Budi Pratama',
      unit: 'Lantai 2 - A12',
      month: 'Oktober 2023',
      amount: 'Rp 2.500.000',
      date: '12 Okt 2023',
      status: _PaymentStatus.pending,
      avatarColor: Color(0xFFDCEEFE),
      avatarTextColor: Color(0xFF0077B6),
    ),
    _PaymentEntry(
      no: '02',
      initials: 'SL',
      tenantName: 'Siti Lestari',
      unit: 'Lantai 1 - B05',
      month: 'Oktober 2023',
      amount: 'Rp 1.850.000',
      date: '10 Okt 2023',
      status: _PaymentStatus.verified,
      avatarColor: Color(0xFFE5E7EB),
      avatarTextColor: Color(0xFF6B7280),
    ),
    _PaymentEntry(
      no: '03',
      initials: 'AM',
      tenantName: 'Andi Mahendra',
      unit: 'Lantai 3 - C01',
      month: 'Oktober 2023',
      amount: 'Rp 2.100.000',
      date: '09 Okt 2023',
      status: _PaymentStatus.rejected,
      avatarColor: Color(0xFFFEE2E2),
      avatarTextColor: Color(0xFFDC2626),
    ),
    _PaymentEntry(
      no: '04',
      initials: 'RW',
      tenantName: 'Rian Wijaya',
      unit: 'Lantai 2 - A08',
      month: 'Oktober 2023',
      amount: 'Rp 2.500.000',
      date: '09 Okt 2023',
      status: _PaymentStatus.pending,
      avatarColor: Color(0xFFDCEEFE),
      avatarTextColor: Color(0xFF0077B6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, isMobile),
        SizedBox(height: isMobile ? 20 : 24),
        _buildPaymentTableCard(context, isMobile),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verifikasi Pembayaran',
                style: TextStyle(
                  fontSize: isMobile ? 26 : 34,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Periksa dan validasi bukti transfer pembayaran sewa dari para penyewa unit Rumah Sewa Biru Laut secara akurat.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              // const SizedBox(height: 14),
              // _exportButton(isCompact: true),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verifikasi Pembayaran',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Periksa dan validasi bukti transfer pembayaran sewa dari para penyewa unit Rumah Sewa Biru Laut secara akurat.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  Widget _exportButton({required bool isCompact}) {
    return Container(
      height: isCompact ? 42 : 46,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.file_download_outlined,
            size: 18,
            color: Color(0xFF111827),
          ),
          const SizedBox(width: 8),
          Text(
            'Ekspor Data',
            style: TextStyle(
              fontSize: isCompact ? 13 : 15,
              color: const Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTableCard(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8ECF4)),
      ),
      child: Column(
        children: [
          _buildFilterBar(isMobile),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7EDF5)),
            ),
            child: isMobile ? _buildMobileList() : _buildDesktopTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _FilterChip(label: 'Semua Status', isSelected: true),
                    _FilterChip(label: 'Menunggu Verifikasi'),
                    _FilterChip(label: 'Terverifikasi'),
                    _FilterChip(label: 'Ditolak'),
                  ],
                ),
                const SizedBox(height: 10),
                _searchField(),
                const SizedBox(height: 10),
                _monthButton(),
              ],
            )
          : Row(
              children: [
                const _FilterChip(label: 'Semua Status', isSelected: true),
                const SizedBox(width: 8),
                const _FilterChip(label: 'Menunggu Verifikasi'),
                const SizedBox(width: 8),
                const _FilterChip(label: 'Terverifikasi'),
                const SizedBox(width: 8),
                const _FilterChip(label: 'Ditolak'),
                const SizedBox(width: 12),
                Expanded(child: _searchField()),
                const SizedBox(width: 12),
                _monthButton(),
              ],
            ),
    );
  }

  Widget _searchField() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFF9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cari nama penyewa atau nomor unit...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7A889C),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthButton() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bulan Ini (Okt)',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280), size: 20),
        ],
      ),
    );
  }

  Widget _buildDesktopTable() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: const Row(
            children: [
              _TableHeaderCell(text: 'NO', flex: 1),
              _TableHeaderCell(text: 'PENYEWA', flex: 4),
              _TableHeaderCell(text: 'UNIT/KAMAR', flex: 3),
              _TableHeaderCell(text: 'BULAN', flex: 3),
              _TableHeaderCell(text: 'JUMLAH', flex: 3),
              _TableHeaderCell(text: 'TANGGAL', flex: 2),
              _TableHeaderCell(text: 'STATUS', flex: 4),
              _TableHeaderCell(
                text: 'AKSI',
                flex: 4,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        for (final entry in _entries) _desktopRow(entry),
        _tableFooter(),
      ],
    );
  }

  Widget _desktopRow(_PaymentEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEFF3F8))),
      ),
      child: Row(
        children: [
          _TableTextCell(text: entry.no, flex: 1),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: entry.avatarColor,
                  child: Text(
                    entry.initials,
                    style: TextStyle(
                      fontSize: 11,
                      color: entry.avatarTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.tenantName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _TableTextCell(text: entry.unit, flex: 3),
          _TableTextCell(text: entry.month, flex: 3),
          _TableTextCell(
            text: entry.amount,
            flex: 3,
            textStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF005D90),
              fontWeight: FontWeight.w700,
            ),
          ),
          _TableTextCell(text: entry.date, flex: 2),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _statusPill(entry.status),
            ),
          ),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.center,
              child: _actionWidget(entry.status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEFF3F8))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Row(
        children: [
          const Text(
            'Menampilkan 4 dari 28 entri',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          _circlePageButton(icon: Icons.chevron_left, isActive: false),
          const SizedBox(width: 8),
          _circlePageButton(label: '1', isActive: true),
          const SizedBox(width: 8),
          _circlePageButton(label: '2', isActive: false),
          const SizedBox(width: 8),
          _circlePageButton(label: '3', isActive: false),
          const SizedBox(width: 8),
          _circlePageButton(icon: Icons.chevron_right, isActive: false),
        ],
      ),
    );
  }

  Widget _buildMobileList() {
    return Column(
      children: [
        for (final entry in _entries)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEFF3F8))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: entry.avatarColor,
                      child: Text(
                        entry.initials,
                        style: TextStyle(
                          fontSize: 11,
                          color: entry.avatarTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.tenantName,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _statusPill(entry.status),
                const SizedBox(height: 10),
                Text(
                  '${entry.unit} • ${entry.month}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${entry.amount} • ${entry.date}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF005D90),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _actionWidget(entry.status),
                ),
              ],
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Menampilkan 4 dari 28 entri',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionWidget(_PaymentStatus status) {
    if (status == _PaymentStatus.pending) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.image_outlined, size: 18, color: Color(0xFF6B7280)),
          _actionButton(
            label: 'Verifikasi',
            backgroundColor: ConstantColor.primaryColor,
            textColor: Colors.white,
          ),
          _actionButton(
            label: 'Tolak',
            backgroundColor: const Color(0xFFFFF1F2),
            textColor: const Color(0xFFDC2626),
            borderColor: const Color(0xFFFECACA),
          ),
        ],
      );
    }

    if (status == _PaymentStatus.verified) {
      return const Text(
        'Detail',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF374151),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return const Text(
      'Lihat Alasan',
      style: TextStyle(
        fontSize: 13,
        color: Color(0xFF374151),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _statusPill(_PaymentStatus status) {
    final Color backgroundColor;
    final Color textColor;
    final String label;
    final IconData icon;

    switch (status) {
      case _PaymentStatus.pending:
        backgroundColor = const Color(0xFFFDE7D2);
        textColor = const Color(0xFF9A5800);
        label = 'MENUNGGU VERIFIKASI';
        icon = Icons.circle;
        break;
      case _PaymentStatus.verified:
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        label = 'TERVERIFIKASI';
        icon = Icons.check_circle_outline;
        break;
      case _PaymentStatus.rejected:
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        label = 'DITOLAK';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: status == _PaymentStatus.pending ? 7 : 14,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circlePageButton({
    String? label,
    IconData? icon,
    required bool isActive,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isActive ? ConstantColor.primaryColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? ConstantColor.primaryColor
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Icon(
        icon,
        size: 17,
        color: isActive ? Colors.white : const Color(0xFF6B7280),
      ),
    )._withLabel(label, isActive);
  }

  Widget _buildBottomSection(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _statisticCard(isMobile: true),
          const SizedBox(height: 14),
          _actionNeededCard(isMobile: true),
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 2, child: _statisticCard(isMobile: false)),
        const SizedBox(width: 18),
        Expanded(child: _actionNeededCard(isMobile: false)),
      ],
    );
  }

  Widget _statisticCard({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B679B), Color(0xFF005D90)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            bottom: 2,
            child: Icon(
              Icons.sailing_outlined,
              size: isMobile ? 70 : 92,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistik Pembayaran Bulan Ini',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 26,
                runSpacing: 10,
                children: const [
                  _StatItem(label: 'TERKUMPUL', value: 'Rp 142.50M'),
                  _StatItem(label: 'MENUNGGU', value: 'Rp 12.20M'),
                  _StatItem(label: 'TARGET', value: 'Rp 160.00M'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionNeededCard({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EBF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8EAF0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high,
                  size: 18,
                  color: Color(0xFF9A5800),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Aksi Diperlukan',
                style: TextStyle(
                  fontSize: 19,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                height: 1.6,
                fontSize: 16,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: 'Terdapat '),
                TextSpan(
                  text: '12 pembayaran',
                  style: TextStyle(
                    color: Color(0xFF005D90),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text:
                      ' yang belum diverifikasi selama lebih dari 24 jam. Segera validasi untuk menjaga kelancaran arus kas.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? ConstantColor.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isSelected
              ? ConstantColor.primaryColor
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign textAlign;

  const _TableHeaderCell({
    required this.text,
    required this.flex,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: textAlign,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.45,
        ),
      ),
    );
  }
}

class _TableTextCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextStyle? textStyle;

  const _TableTextCell({
    required this.text,
    required this.flex,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style:
            textStyle ??
            const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.45,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

enum _PaymentStatus { pending, verified, rejected }

class _PaymentEntry {
  final String no;
  final String initials;
  final String tenantName;
  final String unit;
  final String month;
  final String amount;
  final String date;
  final _PaymentStatus status;
  final Color avatarColor;
  final Color avatarTextColor;

  const _PaymentEntry({
    required this.no,
    required this.initials,
    required this.tenantName,
    required this.unit,
    required this.month,
    required this.amount,
    required this.date,
    required this.status,
    required this.avatarColor,
    required this.avatarTextColor,
  });
}

extension on Widget {
  Widget _withLabel(String? label, bool isActive) {
    if (label == null) return this;

    return Stack(
      alignment: Alignment.center,
      children: [
        this,
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
