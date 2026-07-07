import 'package:flutter/material.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/utils/helpers/currency_format.dart';

class PaymentsHeaderSection extends StatelessWidget {
  final bool isMobile;

  const PaymentsHeaderSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
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
}

class PaymentsFilterBar extends StatelessWidget {
  final bool isMobile;
  final PaymentFilterStatus selectedFilter;
  final ValueChanged<PaymentFilterStatus> onFilterSelected;

  const PaymentsFilterBar({
    super.key,
    required this.isMobile,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
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
                Wrap(spacing: 8, runSpacing: 8, children: _buildChips()),
              ],
            )
          : Row(children: _buildDesktopChips()),
    );
  }

  List<Widget> _buildChips() {
    return [
      PaymentFilterChip(
        label: 'Semua Status',
        isSelected: selectedFilter == PaymentFilterStatus.all,
        onTap: () => onFilterSelected(PaymentFilterStatus.all),
      ),
      PaymentFilterChip(
        label: 'Menunggu Verifikasi',
        isSelected: selectedFilter == PaymentFilterStatus.pendingVerification,
        onTap: () => onFilterSelected(PaymentFilterStatus.pendingVerification),
      ),
      PaymentFilterChip(
        label: 'Terverifikasi',
        isSelected: selectedFilter == PaymentFilterStatus.verified,
        onTap: () => onFilterSelected(PaymentFilterStatus.verified),
      ),
      PaymentFilterChip(
        label: 'Ditolak',
        isSelected: selectedFilter == PaymentFilterStatus.rejected,
        onTap: () => onFilterSelected(PaymentFilterStatus.rejected),
      ),
    ];
  }

  List<Widget> _buildDesktopChips() {
    final chips = _buildChips();
    final widgets = <Widget>[];
    for (int i = 0; i < chips.length; i++) {
      widgets.add(chips[i]);
      if (i != chips.length - 1) {
        widgets.add(const SizedBox(width: 8));
      }
    }
    return widgets;
  }
}

class PaymentDesktopTable extends StatelessWidget {
  final List<PaymentVerificationItem> entries;
  final VoidCallback onReload;
  final ValueChanged<PaymentVerificationItem> onShowProofFile;

  const PaymentDesktopTable({
    super.key,
    required this.entries,
    required this.onReload,
    required this.onShowProofFile,
  });

  @override
  Widget build(BuildContext context) {
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
              PaymentTableHeaderCell(text: 'NO', flex: 1),
              PaymentTableHeaderCell(text: 'PENYEWA', flex: 2),
              PaymentTableHeaderCell(text: 'UNIT/KAMAR', flex: 3),
              PaymentTableHeaderCell(text: 'BULAN', flex: 3),
              PaymentTableHeaderCell(text: 'JUMLAH', flex: 3),
              PaymentTableHeaderCell(text: 'TANGGAL', flex: 2),
              PaymentTableHeaderCell(text: 'STATUS', flex: 4),
              PaymentTableHeaderCell(
                text: 'AKSI',
                flex: 4,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        for (final entry in entries) _desktopRow(entry, context),
        _tableFooter(entries.length),
      ],
    );
  }

  Widget _desktopRow(PaymentVerificationItem entry, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEFF3F8))),
      ),
      child: Row(
        children: [
          PaymentTableTextCell(text: entry.no, flex: 1),
          Expanded(
            flex: 2,
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
          PaymentTableTextCell(text: entry.unit, flex: 3),
          PaymentTableTextCell(text: entry.month, flex: 3),
          PaymentTableTextCell(
            text: currencyIdr.format(
              int.tryParse(entry.amount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
            ),
            flex: 3,
            textStyle: const TextStyle(
              fontSize: 16,
              color: Color(0xFF005D90),
              fontWeight: FontWeight.w700,
            ),
          ),
          PaymentTableTextCell(text: entry.date, flex: 2),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.centerLeft,
              child: PaymentStatusPill(status: entry.status),
            ),
          ),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.center,
              child: PaymentActionWidget(
                status: entry.status,
                onViewImage: () => onShowProofFile(entry),
              ),
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
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class PaymentMobileList extends StatelessWidget {
  final List<PaymentVerificationItem> entries;
  final VoidCallback onReload;

  const PaymentMobileList({
    super.key,
    required this.entries,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
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
                      backgroundColor: paymentAvatarBackground(
                        entry.avatarColorKey,
                      ),
                      child: Text(
                        entry.initials,
                        style: TextStyle(
                          fontSize: 11,
                          color: paymentAvatarText(entry.avatarColorKey),
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
                PaymentStatusPill(status: entry.status),
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
                  child: PaymentActionWidget(status: entry.status),
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
              TextButton(onPressed: onReload, child: const Text('Refresh')),
            ],
          ),
        ),
      ],
    );
  }
}

Color paymentAvatarBackground(int colorKey) {
  if (colorKey == 1) {
    return const Color(0xFFDCEEFE);
  }
  if (colorKey == 2) {
    return const Color(0xFFE8EEF5);
  }
  return const Color(0xFFE5E7EB);
}

Color paymentAvatarText(int colorKey) {
  if (colorKey == 1) {
    return const Color(0xFF0077B6);
  }
  if (colorKey == 2) {
    return const Color(0xFF374151);
  }
  return const Color(0xFF6B7280);
}

class PaymentActionWidget extends StatelessWidget {
  final PaymentVerificationStatus status;
  final VoidCallback? onViewImage;

  const PaymentActionWidget({
    super.key,
    required this.status,
    this.onViewImage,
  });

  @override
  Widget build(BuildContext context) {
    if (status == PaymentVerificationStatus.pending) {
      return Row(
        children: [
          IconButton(
            onPressed: onViewImage,
            icon: const Icon(
              Icons.image_outlined,
              size: 18,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 8),
          PaymentActionButton(
            label: 'Verifikasi',
            backgroundColor: ConstantColor.primaryColor,
            textColor: Colors.white,
          ),
          const SizedBox(width: 8),
          PaymentActionButton(
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
}

class PaymentActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const PaymentActionButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
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
}

class PaymentStatusPill extends StatelessWidget {
  final PaymentVerificationStatus status;

  const PaymentStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
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

class PaymentFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const PaymentFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

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

class PaymentTableHeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign textAlign;

  const PaymentTableHeaderCell({
    super.key,
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

class PaymentTableTextCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextStyle? textStyle;

  const PaymentTableTextCell({
    super.key,
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
