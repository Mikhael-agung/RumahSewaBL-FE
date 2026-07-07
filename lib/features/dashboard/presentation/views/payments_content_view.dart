import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';

class PaymentsContentView extends StatefulWidget {
  const PaymentsContentView({super.key});

  @override
  State<PaymentsContentView> createState() => _PaymentsContentViewState();
}

class _PaymentsContentViewState extends State<PaymentsContentView> {
  late PaymentsController _controller;
  PaymentFilterStatus _selectedFilter = PaymentFilterStatus.all;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<PaymentsController>()) {
      _controller = Get.find<PaymentsController>();
    } else {
      _controller = Get.put(PaymentsController());
    }
  }

  void _reloadPayments() {
    _controller.fetchPayments(status: _selectedFilter);
  }

  void _onFilterSelected(PaymentFilterStatus filter) {
    if (_selectedFilter == filter) {
      return;
    }
    setState(() {
      _selectedFilter = filter;
    });
    _controller.fetchPayments(status: filter);
  }

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
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7EDF5)),
              ),
              child: _buildPaymentContent(isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent(bool isMobile) {
    if (_controller.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller.errorMessage.value.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gagal memuat data pembayaran.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB91C1C),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _controller.errorMessage.value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _reloadPayments,
              child: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    final entries = _controller.payments;
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'Belum ada pembayaran yang perlu diverifikasi.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    return isMobile ? _buildMobileList(entries) : _buildDesktopTable(entries);
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
                  children: [
                    _FilterChip(
                      label: 'Semua Status',
                      isSelected: _selectedFilter == PaymentFilterStatus.all,
                      onTap: () => _onFilterSelected(PaymentFilterStatus.all),
                    ),
                    _FilterChip(
                      label: 'Menunggu Verifikasi',
                      isSelected:
                          _selectedFilter ==
                          PaymentFilterStatus.pendingVerification,
                      onTap: () => _onFilterSelected(
                        PaymentFilterStatus.pendingVerification,
                      ),
                    ),
                    _FilterChip(
                      label: 'Terverifikasi',
                      isSelected:
                          _selectedFilter == PaymentFilterStatus.verified,
                      onTap: () =>
                          _onFilterSelected(PaymentFilterStatus.verified),
                    ),
                    _FilterChip(
                      label: 'Ditolak',
                      isSelected:
                          _selectedFilter == PaymentFilterStatus.rejected,
                      onTap: () =>
                          _onFilterSelected(PaymentFilterStatus.rejected),
                    ),
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
                _FilterChip(
                  label: 'Semua Status',
                  isSelected: _selectedFilter == PaymentFilterStatus.all,
                  onTap: () => _onFilterSelected(PaymentFilterStatus.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Menunggu Verifikasi',
                  isSelected:
                      _selectedFilter ==
                      PaymentFilterStatus.pendingVerification,
                  onTap: () => _onFilterSelected(
                    PaymentFilterStatus.pendingVerification,
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Terverifikasi',
                  isSelected: _selectedFilter == PaymentFilterStatus.verified,
                  onTap: () => _onFilterSelected(PaymentFilterStatus.verified),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Ditolak',
                  isSelected: _selectedFilter == PaymentFilterStatus.rejected,
                  onTap: () => _onFilterSelected(PaymentFilterStatus.rejected),
                ),
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

  Widget _buildDesktopTable(List<PaymentVerificationItem> entries) {
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
        for (final entry in entries) _desktopRow(entry),
        _tableFooter(entries.length),
      ],
    );
  }

  Widget _desktopRow(PaymentVerificationItem entry) {
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
                  backgroundColor: _avatarBackground(entry.avatarColorKey),
                  child: Text(
                    entry.initials,
                    style: TextStyle(
                      fontSize: 11,
                      color: _avatarText(entry.avatarColorKey),
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

  Widget _tableFooter(int totalEntries) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEFF3F8))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Row(
        children: [
          Text(
            'Menampilkan $totalEntries entri',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _reloadPayments,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<PaymentVerificationItem> entries) {
    return Column(
      children: [
        for (final entry in entries)
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
                      backgroundColor: _avatarBackground(entry.avatarColorKey),
                      child: Text(
                        entry.initials,
                        style: TextStyle(
                          fontSize: 11,
                          color: _avatarText(entry.avatarColorKey),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Menampilkan ${entries.length} entri',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: _reloadPayments,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _avatarBackground(int colorKey) {
    if (colorKey == 1) {
      return const Color(0xFFDCEEFE);
    }
    if (colorKey == 2) {
      return const Color(0xFFE8EEF5);
    }
    return const Color(0xFFE5E7EB);
  }

  Color _avatarText(int colorKey) {
    if (colorKey == 1) {
      return const Color(0xFF0077B6);
    }
    if (colorKey == 2) {
      return const Color(0xFF374151);
    }
    return const Color(0xFF6B7280);
  }

  Widget _actionWidget(PaymentVerificationStatus status) {
    if (status == PaymentVerificationStatus.pending) {
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

    if (status == PaymentVerificationStatus.verified) {
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

  Widget _statusPill(PaymentVerificationStatus status) {
    final Color backgroundColor;
    final Color textColor;
    final String label;
    final IconData icon;

    switch (status) {
      case PaymentVerificationStatus.pending:
        backgroundColor = const Color(0xFFFDE7D2);
        textColor = const Color(0xFF9A5800);
        label = 'MENUNGGU VERIFIKASI';
        icon = Icons.circle;
        break;
      case PaymentVerificationStatus.verified:
        backgroundColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF15803D);
        label = 'TERVERIFIKASI';
        icon = Icons.check_circle_outline;
        break;
      case PaymentVerificationStatus.rejected:
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
            size: status == PaymentVerificationStatus.pending ? 7 : 14,
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({required this.label, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
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
