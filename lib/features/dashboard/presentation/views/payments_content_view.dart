import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_bloc.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/widgets/payments_ui_components.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rumah_sewa_biru_laut_fe/utils/helpers/web_network_image_embed_stub.dart'
    if (dart.library.html) 'package:rumah_sewa_biru_laut_fe/utils/helpers/web_network_image_embed_web.dart'
    as web_network_image_embed;
import 'package:rumah_sewa_biru_laut_fe/utils/helpers/web_pdf_embed_stub.dart'
    if (dart.library.html) 'package:rumah_sewa_biru_laut_fe/utils/helpers/web_pdf_embed_web.dart'
    as web_pdf_embed;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PaymentsContentView extends StatefulWidget {
  const PaymentsContentView({super.key});

  @override
  State<PaymentsContentView> createState() => _PaymentsContentViewState();
}

class _PaymentsContentViewState extends State<PaymentsContentView> {
  late PaymentsBloc _paymentsBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paymentsBloc = context.read<PaymentsBloc>();
  }

  void _reloadPayments() {
    _paymentsBloc.add(
      PaymentsFetched(status: _paymentsBloc.state.selectedFilter),
    );
  }

  void _onFilterSelected(PaymentFilterStatus filter) {
    if (_paymentsBloc.state.selectedFilter == filter) {
      return;
    }
    _paymentsBloc.add(PaymentFilterChanged(filter));
  }

  Future<void> _onExportData() async {
    final initialQuery = PaymentExportQuery(
      status: _paymentsBloc.state.selectedFilter.toExportStatus,
    );
    final query = await showDialog<PaymentExportQuery>(
      context: context,
      builder: (_) => PaymentExportFilterDialog(
        initialQuery: initialQuery,
        repository: _paymentsBloc.repository,
      ),
    );
    if (!mounted || query == null) {
      return;
    }

    _paymentsBloc.add(PaymentExportRequested(query: query));
  }

  void _showProofFile(BuildContext context, PaymentVerificationItem entry) {
    final proofUrl = entry.proofFileUrl;
    if (proofUrl == null || proofUrl.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Bukti Transfer'),
          content: const Text('Bukti transfer tidak tersedia.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }

    final extension = proofExtension(entry);
    final normalizedProofUrl = normalizeProofUrl(proofUrl);

    if (extension == 'pdf') {
      if (kIsWeb) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Bukti Transfer (PDF)'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.75,
              child: web_pdf_embed.buildWebPdfEmbed(normalizedProofUrl),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Bukti Transfer (PDF)'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.75,
            child: SfPdfViewer.network(
              normalizedProofUrl,
              onDocumentLoadFailed: (_) {
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal memuat file PDF.')),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Bukti Transfer'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child: kIsWeb
              ? web_network_image_embed.buildWebNetworkImageEmbed(
                  normalizedProofUrl,
                )
              : CachedNetworkImage(
                  imageUrl: normalizedProofUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Center(child: Icon(Icons.error)),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _onUpdatePaymentStatus(
    BuildContext context,
    PaymentVerificationItem entry,
    PaymentVerificationStatus targetStatus,
  ) async {
    if (entry.paymentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID pembayaran tidak ditemukan.')),
      );
      return;
    }

    final note = await _showStatusUpdateDialog(context, targetStatus);
    if (!mounted || note == null) {
      return;
    }

    _paymentsBloc.add(
      PaymentStatusUpdateRequested(
        paymentId: entry.paymentId,
        status: targetStatus,
        rejectionReason: targetStatus == PaymentVerificationStatus.rejected
            ? note
            : null,
      ),
    );
  }

  Future<String?> _showStatusUpdateDialog(
    BuildContext context,
    PaymentVerificationStatus targetStatus,
  ) {
    return showDialog<String>(
      context: context,
      builder: (_) => _PaymentStatusDialog(targetStatus: targetStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return BlocListener<PaymentsBloc, PaymentsState>(
      listenWhen: (previous, current) =>
          previous.actionErrorMessage != current.actionErrorMessage ||
          previous.actionSuccessMessage != current.actionSuccessMessage,
      listener: (context, state) {
        if (state.actionErrorMessage.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionErrorMessage)));
        }
        if (state.actionSuccessMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionSuccessMessage),
              backgroundColor: const Color(0xFF047857),
            ),
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentsHeaderSection(
            isMobile: isMobile,
            onExportPressed: () {
              _onExportData();
            },
            isExporting: context.select(
              (PaymentsBloc bloc) => bloc.state.isExporting,
            ),
          ),
          SizedBox(height: isMobile ? 20 : 24),
          _buildPaymentTableCard(context, isMobile),
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
          PaymentsFilterBar(
            isMobile: isMobile,
            selectedFilter: context.select(
              (PaymentsBloc bloc) => bloc.state.selectedFilter,
            ),
            onFilterSelected: _onFilterSelected,
          ),
          const SizedBox(height: 14),
          BlocBuilder<PaymentsBloc, PaymentsState>(
            builder: (context, state) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7EDF5)),
              ),
              child: _buildPaymentContent(context, isMobile, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent(
    BuildContext context,
    bool isMobile,
    PaymentsState state,
  ) {
    if (state.isLoading) {
      return isMobile ? _buildMobileShimmer() : _buildDesktopShimmer();
    }

    if (state.errorMessage.isNotEmpty) {
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
              state.errorMessage,
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

    final entries = state.payments;
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

    return isMobile
        ? PaymentMobileList(
            entries: entries,
            onReload: _reloadPayments,
            onVerifyPayment: (entry) => _onUpdatePaymentStatus(
              context,
              entry,
              PaymentVerificationStatus.verified,
            ),
            onRejectPayment: (entry) => _onUpdatePaymentStatus(
              context,
              entry,
              PaymentVerificationStatus.rejected,
            ),
            verifyingPaymentIds: state.verifyingPaymentIds,
          )
        : PaymentDesktopTable(
            entries: entries,
            onReload: _reloadPayments,
            onShowProofFile: (entry) => _showProofFile(context, entry),
            onVerifyPayment: (entry) => _onUpdatePaymentStatus(
              context,
              entry,
              PaymentVerificationStatus.verified,
            ),
            onRejectPayment: (entry) => _onUpdatePaymentStatus(
              context,
              entry,
              PaymentVerificationStatus.rejected,
            ),
            verifyingPaymentIds: state.verifyingPaymentIds,
          );
  }

  Widget _buildDesktopShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF1F5F9),
      highlightColor: const Color(0xFFE2E8F0),
      child: Column(
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
          ...List.generate(4, (_) => _buildDesktopShimmerRow()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFEFF3F8))),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                _buildShimmerBox(width: 130, height: 13),
                const Spacer(),
                _buildShimmerBox(width: 68, height: 30, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopShimmerRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEFF3F8))),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: _buildShimmerBox(height: 12)),
          Expanded(flex: 2, child: _buildShimmerBox(height: 14)),
          Expanded(flex: 3, child: _buildShimmerBox(height: 14)),
          Expanded(flex: 3, child: _buildShimmerBox(height: 14)),
          Expanded(flex: 3, child: _buildShimmerBox(height: 14)),
          Expanded(flex: 2, child: _buildShimmerBox(height: 14)),
          Expanded(flex: 4, child: _buildShimmerBox(height: 28, radius: 999)),
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.center,
              child: _buildShimmerBox(width: 96, height: 30, radius: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFF1F5F9),
      highlightColor: const Color(0xFFE2E8F0),
      child: Column(
        children: [
          ...List.generate(
            3,
            (_) => Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFEFF3F8))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _buildShimmerBox(height: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildShimmerBox(width: 128, height: 24, radius: 999),
                  const SizedBox(height: 10),
                  _buildShimmerBox(width: 170, height: 12),
                  const SizedBox(height: 8),
                  _buildShimmerBox(width: 150, height: 13),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildShimmerBox(width: 96, height: 30, radius: 8),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _buildShimmerBox(width: 128, height: 13),
                const Spacer(),
                _buildShimmerBox(width: 68, height: 28, radius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({
    double? width,
    required double height,
    double radius = 4,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _PaymentStatusDialog extends StatefulWidget {
  final PaymentVerificationStatus targetStatus;

  const _PaymentStatusDialog({required this.targetStatus});

  @override
  State<_PaymentStatusDialog> createState() => _PaymentStatusDialogState();
}

class _PaymentStatusDialogState extends State<_PaymentStatusDialog> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReject = widget.targetStatus == PaymentVerificationStatus.rejected;

    return AlertDialog(
      title: Text(isReject ? 'Tolak Pembayaran' : 'Verifikasi Pembayaran'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isReject
                ? 'Anda akan menolak pembayaran ini.'
                : 'Anda akan memverifikasi pembayaran ini.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: isReject
                  ? 'Alasan penolakan (opsional)'
                  : 'Catatan verifikasi (opsional)',
              hintText: isReject
                  ? 'Contoh: nominal transfer tidak sesuai'
                  : 'Tambahkan catatan bila perlu',
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isReject
                ? const Color(0xFFDC2626)
                : const Color(0xFF0F766E),
          ),
          onPressed: () =>
              Navigator.of(context).pop(_noteController.text.trim()),
          child: Text(isReject ? 'Tolak' : 'Verifikasi'),
        ),
      ],
    );
  }
}
