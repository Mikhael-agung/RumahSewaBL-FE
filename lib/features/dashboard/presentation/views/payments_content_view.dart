import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/views/widgets/payments_ui_components.dart';
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

    final extension = _controller.proofExtension(entry);

    if (extension == 'pdf') {
      if (kIsWeb) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Bukti Transfer (PDF)'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.75,
              child: web_pdf_embed.buildWebPdfEmbed(proofUrl),
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
              proofUrl,
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
                  proofUrl,
                )
              : CachedNetworkImage(
                  imageUrl: proofUrl,
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentsHeaderSection(isMobile: isMobile),
        SizedBox(height: isMobile ? 20 : 24),
        _buildPaymentTableCard(context, isMobile),
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
          PaymentsFilterBar(
            isMobile: isMobile,
            selectedFilter: _selectedFilter,
            onFilterSelected: _onFilterSelected,
          ),
          const SizedBox(height: 14),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7EDF5)),
              ),
              child: _buildPaymentContent(context, isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent(BuildContext context, bool isMobile) {
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

    return isMobile
        ? PaymentMobileList(entries: entries, onReload: _reloadPayments)
        : PaymentDesktopTable(
            entries: entries,
            onReload: _reloadPayments,
            onShowProofFile: (entry) => _showProofFile(context, entry),
          );
  }
}
