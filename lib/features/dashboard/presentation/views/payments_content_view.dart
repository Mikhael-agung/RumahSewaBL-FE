import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:rumah_sewa_biru_laut_fe/core/controllers/user_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/core/routes/route_name.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/global_notification_service.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_bloc.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/widgets/payments_ui_components.dart';
import 'package:rumah_sewa_biru_laut_fe/utils/helpers/currency_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isSessionExpiredDialogVisible = false;
  int _pageIndex = 0;
  static const int _pageSize = 10;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _paymentsBloc = context.read<PaymentsBloc>();
  }

  void _reloadPayments() {
    setState(() => _pageIndex = 0);
    _paymentsBloc.add(
      PaymentsFetched(status: _paymentsBloc.state.selectedFilter),
    );
  }

  void _onFilterSelected(PaymentFilterStatus filter) {
    if (_paymentsBloc.state.selectedFilter == filter) {
      return;
    }
    setState(() => _pageIndex = 0);
    _paymentsBloc.add(PaymentFilterChanged(filter));
  }

  void _setPage(int page) {
    setState(() {
      _pageIndex = page;
    });
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

  Future<void> _handleUnauthenticatedSession() async {
    if (!mounted || _isSessionExpiredDialogVisible) {
      return;
    }
    _isSessionExpiredDialogVisible = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Sesi Berakhir'),
          content: const Text(
            'Sesi login Anda sudah berakhir. Silakan login kembali untuk melanjutkan.',
          ),
          actions: [
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _redirectToLogin();
              },
              child: const Text('Ke Halaman Login'),
            ),
          ],
        ),
      );
    } finally {
      _isSessionExpiredDialogVisible = false;
    }
  }

  Future<void> _redirectToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    await prefs.remove('user_username');
    await prefs.remove('user_role');

    if (Get.isRegistered<UserController>()) {
      final userController = Get.find<UserController>();
      userController.clearUserData();
      userController.changeMenu('Dashboard');
    }

    if (Get.isRegistered<GlobalNotificationService>()) {
      await Get.find<GlobalNotificationService>().stopPolling(clearState: true);
    }

    if (!mounted) {
      return;
    }
    context.replace(RouteName.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return BlocListener<PaymentsBloc, PaymentsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.actionErrorMessage != current.actionErrorMessage ||
          previous.actionSuccessMessage != current.actionSuccessMessage,
      listener: (context, state) {
        if (state.hasUnauthenticatedError) {
          _handleUnauthenticatedSession();
          return;
        }

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

    final totalPages = (entries.length / _pageSize).ceil().clamp(1, 999);
    final safePage = _pageIndex.clamp(0, totalPages - 1);
    if (safePage != _pageIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _pageIndex = safePage);
      });
    }

    final start = safePage * _pageSize;
    final end = (start + _pageSize).clamp(0, entries.length);
    final pageEntries = entries.sublist(start, end);

    return isMobile
        ? PaymentMobileList(
            entries: pageEntries,
            totalEntries: entries.length,
            startEntry: start + 1,
            endEntry: end,
            currentPage: safePage,
            totalPages: totalPages,
            onPageChanged: _setPage,
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
            onViewDetailPayment: (entry) => _showVerifiedPaymentDetail(entry),
            verifyingPaymentIds: state.verifyingPaymentIds,
          )
        : PaymentDesktopTable(
            entries: pageEntries,
            totalEntries: entries.length,
            startEntry: start + 1,
            endEntry: end,
            currentPage: safePage,
            totalPages: totalPages,
            onPageChanged: _setPage,
            onViewDetailPayment: (entry) => _showVerifiedPaymentDetail(entry),
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

  void _showVerifiedPaymentDetail(PaymentVerificationItem entry) {
    if (entry.status != PaymentVerificationStatus.verified) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (_) => _VerifiedPaymentDetailDialog(
        entry: entry,
        onViewProof: () => _showProofFile(context, entry),
      ),
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

class _VerifiedPaymentDetailDialog extends StatelessWidget {
  final PaymentVerificationItem entry;
  final VoidCallback onViewProof;

  const _VerifiedPaymentDetailDialog({
    required this.entry,
    required this.onViewProof,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final amountDigits = int.tryParse(
      entry.amount.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    final tenantDisplay = _buildTenantDisplay();
    final paymentMethod = (entry.paymentMethod ?? '').trim().isEmpty
        ? 'Upload Mandiri'
        : entry.paymentMethod!.trim();
    final verificationLine = _buildVerificationLine();
    final proofUrl = entry.proofFileUrl;
    final hasProof = proofUrl != null && proofUrl.isNotEmpty;
    final proofType = proofExtension(entry);
    final note = (entry.tenantNote ?? '').trim().isEmpty
        ? '"Pembayaran sewa bulan ${entry.month} lunas. Terima kasih."'
        : '"${entry.tenantNote!.trim()}"';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 780 : 380,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Detail Pembayaran',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF111827),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, size: 16),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFE5E7EB),
                            foregroundColor: const Color(0xFF6B7280),
                            minimumSize: const Size(24, 24),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'ID Transaksi: ${entry.paymentId.isEmpty ? '-' : entry.paymentId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 18),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Color(0xFF065F46),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'TERVERIFIKASI',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF065F46),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildDetailLayout(
                      isDesktop: isDesktop,
                      tenantDisplay: tenantDisplay,
                      amountValue: amountDigits == null
                          ? entry.amount
                          : currencyIdr.format(amountDigits),
                      paymentMethod: paymentMethod,
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Color(0xFF047857),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            verificationLine,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'BUKTI PEMBAYARAN',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: hasProof ? onViewProof : null,
                          icon: const Icon(Icons.download_rounded, size: 14),
                          label: const Text('Unduh'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF005D90),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            minimumSize: const Size(0, 30),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildProofPreview(
                      hasProof: hasProof,
                      proofUrl: proofUrl,
                      proofType: proofType,
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CATATAN PENYEWA',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            note,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF374151),
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF475569),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildTenantDisplay() {
    final code = (entry.tenantCode ?? '').trim();
    if (code.isEmpty || entry.tenantName == '-') {
      return entry.tenantName;
    }
    return '${entry.tenantName}  ($code)';
  }

  String _buildVerificationLine() {
    final by = (entry.verificationBy ?? '').trim().isEmpty
        ? 'Manager Aktif'
        : entry.verificationBy!.trim();
    final at = (entry.verifiedAtLabel ?? '').trim();
    if (at.isEmpty || at == '-') {
      return 'Diverifikasi oleh: $by';
    }
    return 'Diverifikasi oleh: $by • $at';
  }

  Widget _buildDetailLayout({
    required bool isDesktop,
    required String tenantDisplay,
    required String amountValue,
    required String paymentMethod,
  }) {
    if (!isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailGridItem('PENYEWA', tenantDisplay),
          const SizedBox(height: 12),
          _detailGridItem('UNIT/KAMAR', entry.unit),
          const SizedBox(height: 12),
          _detailGridItem('BULAN SEWA', entry.month),
          const SizedBox(height: 12),
          _detailGridItem(
            'JUMLAH PEMBAYARAN',
            amountValue,
            valueColor: const Color(0xFF005D90),
            valueWeight: FontWeight.w700,
          ),
          const SizedBox(height: 12),
          _detailGridItem('METODE', paymentMethod, isBadge: true),
          const SizedBox(height: 12),
          _detailGridItem('TANGGAL TRANSFER', entry.date),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailGridItem('PENYEWA', tenantDisplay),
              const SizedBox(height: 14),
              _detailGridItem('BULAN SEWA', entry.month),
              const SizedBox(height: 14),
              _detailGridItem('METODE', paymentMethod, isBadge: true),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailGridItem('UNIT/KAMAR', entry.unit),
              const SizedBox(height: 14),
              _detailGridItem(
                'JUMLAH PEMBAYARAN',
                amountValue,
                valueColor: const Color(0xFF005D90),
                valueWeight: FontWeight.w700,
              ),
              const SizedBox(height: 14),
              _detailGridItem('TANGGAL TRANSFER', entry.date),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProofPreview({
    required bool hasProof,
    required String? proofUrl,
    required String proofType,
    required bool isDesktop,
  }) {
    return InkWell(
      onTap: hasProof ? onViewProof : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: isDesktop ? 290 : 220,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildProofContent(
            hasProof: hasProof,
            proofUrl: proofUrl,
            proofType: proofType,
          ),
        ),
      ),
    );
  }

  Widget _buildProofContent({
    required bool hasProof,
    required String? proofUrl,
    required String proofType,
  }) {
    if (!hasProof || proofUrl == null || proofUrl.isEmpty) {
      return const Center(
        child: Text(
          'Bukti pembayaran belum tersedia.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (proofType == 'pdf') {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_rounded,
              size: 34,
              color: Color(0xFFEF4444),
            ),
            SizedBox(height: 8),
            Text(
              'File PDF tersedia',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Klik untuk melihat dokumen',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    final normalizedUrl = normalizeProofUrl(proofUrl);
    print('Normalized proof URL: $normalizedUrl, \n Original: $proofUrl');
    if (kIsWeb) {
      return web_network_image_embed.buildWebNetworkImageEmbed(normalizedUrl);
    }

    return CachedNetworkImage(
      imageUrl: normalizedUrl,
      fit: BoxFit.contain,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.broken_image_rounded, color: Color(0xFF94A3B8)),
      ),
    );
  }

  Widget _detailGridItem(
    String label,
    String value, {
    Color valueColor = const Color(0xFF111827),
    FontWeight valueWeight = FontWeight.w600,
    bool isBadge = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: valueColor,
              fontWeight: valueWeight,
            ),
          ),
      ],
    );
  }
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
