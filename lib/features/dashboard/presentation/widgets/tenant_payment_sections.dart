import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/tenant_colors.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/variables.dart';

const Color _surfaceBackground = Colors.white;
const int _monthlyRent = 2500000;

BoxDecoration _surfaceDecoration({required double radius}) {
  return BoxDecoration(
    color: _surfaceBackground,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.black.withOpacity(0.05)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

class TenantBillingCard extends StatelessWidget {
  const TenantBillingCard({super.key});

  static const List<String> _monthOptions = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  Future<void> _uploadPaymentProof(BuildContext context) async {
    final monthController = TextEditingController(text: _monthOptions[DateTime.now().month - 1]);
    final yearController = TextEditingController(text: DateTime.now().year.toString());
    final amountController = TextEditingController(text: _monthlyRent.toString());
    final noteController = TextEditingController();
    PlatformFile? selectedFile;

    try {
      final shouldUpload = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: _surfaceBackground,
                insetPadding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upload Bukti Pembayaran',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 21 * _fontScale(context),
                                        fontWeight: FontWeight.w800,
                                        color: TenantColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${monthController.text.trim()} ${yearController.text.trim()} — ${formatCurrency(amountController.text.trim())}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: TenantColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(dialogContext).pop(false),
                                icon: const Icon(Icons.close),
                                color: TenantColors.onSurfaceVariant,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _UploadDropZone(
                            fileName: selectedFile?.name,
                            onTap: () async {
                              final result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: const ['png', 'jpg', 'jpeg', 'pdf'],
                                withData: true,
                              );
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  selectedFile = result.files.first;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _PaymentDropdownField(
                                  value: monthController.text,
                                  items: _monthOptions,
                                  label: 'Bulan pembayaran',
                                  onChanged: (value) {
                                    monthController.text = value ?? monthController.text;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _PaymentField(
                                  controller: yearController,
                                  label: 'Tahun pembayaran',
                                  hintText: '2026',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _PaymentField(
                            controller: amountController,
                            label: 'Jumlah pembayaran',
                            hintText: 'Contoh: 2500000',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          _PaymentField(
                            controller: noteController,
                            label: 'Catatan tambahan',
                            hintText: 'Tambahkan catatan jika diperlukan...',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: selectedFile == null
                                  ? null
                                  : () => Navigator.of(dialogContext).pop(true),
                              icon: const Icon(Icons.upload_file),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Kirim Bukti Bayar'),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: TenantColors.primary,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text('Batal'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      if (shouldUpload != true || selectedFile == null) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      if (token.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token login tidak ditemukan')),
          );
        }
        return;
      }

      final paymentMonth = _monthOptions.indexOf(monthController.text.trim()) + 1;
      final paymentYear = int.tryParse(yearController.text.trim());
      final amount = num.tryParse(amountController.text.trim());

      if (paymentMonth < 1 || paymentMonth > 12) {
        throw Exception('Bulan pembayaran tidak valid');
      }
      if (paymentYear == null || paymentYear < 2020 || paymentYear > 2099) {
        throw Exception('Tahun pembayaran tidak valid');
      }
      if (amount == null || amount <= 0) {
        throw Exception('Jumlah pembayaran harus lebih dari 0');
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: ConstantVariable.apiBaseUrl,
          connectTimeout: ConstantVariable.connectTimeout,
          receiveTimeout: ConstantVariable.receiveTimeout,
        ),
      );

      final formData = FormData.fromMap({
        'payment_month': paymentMonth,
        'payment_year': paymentYear,
        'amount': amount,
        'notes': noteController.text.trim(),
        'proof_file': MultipartFile.fromBytes(
          selectedFile!.bytes!,
          filename: selectedFile!.name,
        ),
      });

      await dio.post(
        '/payments/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti pembayaran berhasil diupload')),
        );
      }
    } on DioException catch (e) {
      final message = _resolveDioMessage(e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      monthController.dispose();
      yearController.dispose();
      amountController.dispose();
      noteController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _surfaceDecoration(radius: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;

          final leftColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'November 2023',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 28 * _fontScale(context),
                  fontWeight: FontWeight.w800,
                  color: TenantColors.onBackground,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCEBD4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFFB05A00)),
                        SizedBox(width: 6),
                        Text(
                          'Deadline: 20 Nov 2023',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB05A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Total Tagihan',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: TenantColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatCurrency(_monthlyRent),
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22 * _fontScale(context),
                  fontWeight: FontWeight.w800,
                  color: TenantColors.onBackground,
                ),
              ),
            ],
          );

          final rightColumn = Column(
            crossAxisAlignment: isWide ? CrossAxisAlignment.end : CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: isWide ? 260 : double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _uploadPaymentProof(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Upload Bukti Bayar'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TenantColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: TenantColors.primary.withOpacity(0.35),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Format PNG, JPG, PDF (Maks 5MB)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: TenantColors.onSurfaceVariant,
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: leftColumn),
                const SizedBox(width: 24),
                rightColumn,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leftColumn,
              const SizedBox(height: 24),
              rightColumn,
            ],
          );
        },
      ),
    );
  }
}

class TenantPaymentsHistoryTableCard extends StatefulWidget {
  const TenantPaymentsHistoryTableCard({super.key});

  @override
  State<TenantPaymentsHistoryTableCard> createState() => _TenantPaymentsHistoryTableCardState();
}

class _TenantPaymentsHistoryTableCardState extends State<TenantPaymentsHistoryTableCard> {
  late Future<List<HistoryItemData>> _historyFuture;
  int _pageIndex = 0;
  static const int _pageSize = 3;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<HistoryItemData>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    if (token.isEmpty) {
      throw Exception('Token login tidak ditemukan');
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: ConstantVariable.apiBaseUrl,
        connectTimeout: ConstantVariable.connectTimeout,
        receiveTimeout: ConstantVariable.receiveTimeout,
      ),
    );

    final response = await dio.get(
      '/payments/history',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return extractHistoryItems(response.data)
        .map((item) => HistoryItemData.fromJson(item))
        .where((item) => item.month.isNotEmpty || item.invoice.isNotEmpty)
        .toList();
  }

  void _setPage(int page) {
    setState(() {
      _pageIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _surfaceDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Pembayaran',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18 * _fontScale(context),
              fontWeight: FontWeight.w800,
              color: TenantColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<HistoryItemData>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    snapshot.error.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              final items = snapshot.data ?? const <HistoryItemData>[];
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Belum ada riwayat pembayaran.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: TenantColors.onSurfaceVariant,
                    ),
                  ),
                );
              }

              final totalPages = (items.length / _pageSize).ceil().clamp(1, 999);
              final safePage = _pageIndex.clamp(0, totalPages - 1);
              if (safePage != _pageIndex) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _pageIndex = safePage);
                  }
                });
              }

              final start = safePage * _pageSize;
              final end = (start + _pageSize).clamp(0, items.length);
              final pageItems = items.sublist(start, end);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.04)),
                    ),
                    child: Row(
                      children: const [
                        Expanded(flex: 4, child: _HistoryHeaderLabel(text: 'BULAN')),
                        Expanded(flex: 3, child: _HistoryHeaderLabel(text: 'TANGGAL')),
                        Expanded(flex: 2, child: _HistoryHeaderLabel(text: 'STATUS')),
                        SizedBox(width: 56, child: _HistoryHeaderLabel(text: 'AKSI')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...pageItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HistoryTableRow(
                        item: item,
                        onActionTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Aksi unduh belum tersedia')),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${start + 1} to $end of ${items.length} entries',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: TenantColors.onSurfaceVariant),
                      ),
                      Row(
                        children: [
                          _PageButton(
                            icon: Icons.chevron_left,
                            enabled: safePage > 0,
                            onTap: safePage > 0 ? () => _setPage(safePage - 1) : null,
                          ),
                          const SizedBox(width: 8),
                          for (var page = 0; page < totalPages && page < 3; page++) ...[
                            _PageNumberButton(
                              number: page + 1,
                              active: page == safePage,
                              onTap: () => _setPage(page),
                            ),
                            if (page < totalPages - 1 && page < 2) const SizedBox(width: 8),
                          ],
                          const SizedBox(width: 8),
                          _PageButton(
                            icon: Icons.chevron_right,
                            enabled: safePage < totalPages - 1,
                            onTap: safePage < totalPages - 1 ? () => _setPage(safePage + 1) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class TenantHistoryCard extends StatefulWidget {
  const TenantHistoryCard({super.key});

  @override
  State<TenantHistoryCard> createState() => _TenantHistoryCardState();
}

class _TenantHistoryCardState extends State<TenantHistoryCard> {
  late Future<List<HistoryItemData>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<HistoryItemData>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    if (token.isEmpty) {
      throw Exception('Token login tidak ditemukan');
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: ConstantVariable.apiBaseUrl,
        connectTimeout: ConstantVariable.connectTimeout,
        receiveTimeout: ConstantVariable.receiveTimeout,
      ),
    );

    final response = await dio.get(
      '/payments/history',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return extractHistoryItems(response.data)
        .map((item) => HistoryItemData.fromJson(item))
        .where((item) => item.month.isNotEmpty || item.invoice.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _surfaceDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Pembayaran',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18 * _fontScale(context),
              fontWeight: FontWeight.w800,
              color: TenantColors.onBackground,
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<List<HistoryItemData>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    snapshot.error.toString().replaceAll('Exception: ', ''),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              final items = snapshot.data ?? const <HistoryItemData>[];
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Belum ada riwayat pembayaran.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: TenantColors.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  ...items.take(2).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _HistoryListItem(item: item),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: TenantColors.primary,
                        side: BorderSide(color: TenantColors.primary.withOpacity(0.20)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        textStyle: const TextStyle(fontWeight: FontWeight.w800),
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text('Lihat Semua Riwayat'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class HistoryItemData {
  final String month;
  final String dateLabel;
  final int? monthNumber;
  final int? year;
  final String invoice;
  final String amount;
  final String status;

  const HistoryItemData({
    required this.month,
    this.dateLabel = '-',
    this.monthNumber,
    this.year,
    required this.invoice,
    required this.amount,
    required this.status,
  });

  factory HistoryItemData.fromJson(dynamic json) {
    if (json is! Map) {
      return const HistoryItemData(month: '', invoice: '', amount: '', status: '');
    }

    final map = json.cast<String, dynamic>();
    final createdAt = asString(map['created_at'] ?? map['payment_date'] ?? map['date']);
    final rawMonth = asString(
      map['month'] ?? map['periode'] ?? map['payment_month'] ?? map['billing_month'] ?? createdAt,
    );
    final rawYear = asString(map['payment_year'] ?? map['year']);
    final monthNumber = _parseMonthNumber(rawMonth);
    final year = int.tryParse(rawYear) ?? _extractYear(createdAt);
    final invoice = asString(
      map['invoice'] ?? map['invoice_number'] ?? map['invoice_no'] ?? map['reference'] ?? map['code'],
    );
    final amountValue = map['amount'] ?? map['total_amount'] ?? map['nominal'] ?? map['price'];
    final status = asString(
      map['status'] ?? map['payment_status'] ?? map['verification_status'] ?? map['state'],
    );

    return HistoryItemData(
      month: formatMonthLabel(rawMonth, year: year, monthNumber: monthNumber),
      dateLabel: formatShortDateLabel(createdAt, year: year, monthNumber: monthNumber),
      monthNumber: monthNumber,
      year: year,
      invoice: invoice.isEmpty ? '-' : invoice,
      amount: formatCurrency(amountValue),
      status: status.isEmpty ? 'Terverifikasi' : normalizeStatus(status),
    );
  }
}

class HistoryItem extends StatelessWidget {
  final String month;
  final String invoice;
  final String amount;
  final String status;

  const HistoryItem({
    super.key,
    required this.month,
    required this.invoice,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TenantColors.background.withOpacity(0.30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TenantColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: TenantColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14 * _fontScale(context),
                    fontWeight: FontWeight.w800,
                    color: TenantColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  invoice,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: TenantColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: TenantColors.onBackground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: statusColor(status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryListItem extends StatelessWidget {
  final HistoryItemData item;

  const _HistoryListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = item.status.trim().toLowerCase();
    final statusColorValue = statusColor(item.status);
    final isVerified = normalizedStatus == 'terverifikasi';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE3EDF6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: TenantColors.primary, width: 1.8),
              ),
              child: const Icon(Icons.check, size: 12, color: TenantColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.month,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: TenantColors.onBackground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.invoice,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: TenantColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.amount,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: TenantColors.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isVerified ? 'TERVERIFIKASI' : item.status.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: statusColorValue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UploadDropZone extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;

  const _UploadDropZone({required this.fileName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD5DADF), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: TenantColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload_rounded, size: 34, color: TenantColors.primary),
            ),
            const SizedBox(height: 14),
            const Text(
              'Seret file ke sini atau klik untuk pilih',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: TenantColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              fileName ?? 'Format PNG, JPG, PDF (Maks 5MB)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: fileName == null ? TenantColors.onSurfaceVariant : TenantColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;

  const _PaymentField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: TenantColors.onSurfaceVariant,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: TenantColors.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

String _monthName(int month) {
  switch (month) {
    case 1:
      return 'Januari';
    case 2:
      return 'Februari';
    case 3:
      return 'Maret';
    case 4:
      return 'April';
    case 5:
      return 'Mei';
    case 6:
      return 'Juni';
    case 7:
      return 'Juli';
    case 8:
      return 'Agustus';
    case 9:
      return 'September';
    case 10:
      return 'Oktober';
    case 11:
      return 'November';
    case 12:
      return 'Desember';
    default:
      return 'Bulan';
  }
}

class _PaymentDropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final String label;
  final ValueChanged<String?> onChanged;

  const _PaymentDropdownField({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: TenantColors.onSurfaceVariant,
            ),
          ),
        ),
        InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: TenantColors.primary, width: 1.4),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: const TextStyle(
                fontSize: 14,
                color: TenantColors.onBackground,
                fontWeight: FontWeight.w500,
              ),
              items: items
                  .map(
                    (month) => DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryHeaderLabel extends StatelessWidget {
  final String text;

  const _HistoryHeaderLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
        color: TenantColors.onSurfaceVariant,
      ),
    );
  }
}

class _HistoryTableRow extends StatelessWidget {
  final HistoryItemData item;
  final VoidCallback onActionTap;

  const _HistoryTableRow({required this.item, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final status = item.status.trim().toLowerCase();
    final statusLabel = status == 'terverifikasi'
        ? 'TERVERIFIKASI'
        : status == 'menunggu'
            ? 'MENUNGGU'
            : status == 'gagal'
                ? 'DITOLAK'
                : item.status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              item.month,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: TenantColors.onBackground),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.dateLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: TenantColors.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 2,
            child: _StatusChip(label: statusLabel, status: item.status),
          ),
          SizedBox(
            width: 56,
            child: IconButton(
              onPressed: onActionTap,
              icon: const Icon(Icons.download_rounded, size: 20),
              color: TenantColors.primary,
              tooltip: 'Aksi',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String status;

  const _StatusChip({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final background = normalized == 'terverifikasi'
        ? const Color(0xFFDFF5EF)
        : normalized == 'menunggu'
            ? const Color(0xFFF9EFD6)
            : const Color(0xFFF9E0E0);
    final foreground = normalized == 'terverifikasi'
        ? const Color(0xFF16866B)
        : normalized == 'menunggu'
            ? const Color(0xFF9A6100)
            : const Color(0xFFB42318);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _PageButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Icon(icon, size: 18, color: enabled ? TenantColors.primary : TenantColors.onSurfaceVariant),
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  final int number;
  final bool active;
  final VoidCallback onTap;

  const _PageNumberButton({required this.number, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? TenantColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? TenantColors.primary : Colors.black.withOpacity(0.05)),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : TenantColors.onBackground,
          ),
        ),
      ),
    );
  }
}

String formatShortDateLabel(String value, {int? year, int? monthNumber}) {
  final normalized = value.trim();
  if (normalized.isNotEmpty) {
    final parsed = DateTime.tryParse(normalized);
    if (parsed != null) {
      return '${parsed.day} ${_shortMonthName(parsed.month)}';
    }
  }

  if (monthNumber != null && monthNumber >= 1 && monthNumber <= 12) {
    return _shortMonthName(monthNumber);
  }

  if (year != null) {
    return '$year';
  }

  return '-';
}

String _shortMonthName(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'Mei';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Agu';
    case 9:
      return 'Sep';
    case 10:
      return 'Okt';
    case 11:
      return 'Nov';
    case 12:
      return 'Des';
    default:
      return '-';
  }
}

int _parseMonthNumber(String value) {
  final normalized = value.trim().toLowerCase();
  const lookup = {
    'januari': 1,
    'februari': 2,
    'maret': 3,
    'april': 4,
    'mei': 5,
    'juni': 6,
    'juli': 7,
    'agustus': 8,
    'september': 9,
    'oktober': 10,
    'november': 11,
    'desember': 12,
  };

  return lookup[normalized] ?? int.tryParse(normalized) ?? 0;
}

int? _extractYear(String value) {
  final match = RegExp(r'(20\d{2})').firstMatch(value);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

class _PillLabel extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;

  const _PillLabel({
    required this.label,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: textColor,
        ),
      ),
    );
  }
}

List<dynamic> extractHistoryItems(dynamic rawData) {
  if (rawData is List) {
    return rawData;
  }

  if (rawData is Map) {
    final map = rawData.cast<String, dynamic>();
    final candidates = [map['data'], map['results'], map['items'], map['payments'], map['history']];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate;
      }
    }
  }

  return const [];
}

String asString(dynamic value) {
  if (value == null) {
    return '';
  }
  return value.toString().trim();
}

String formatCurrency(dynamic value) {
  if (value == null) {
    return '-';
  }

  if (value is num) {
    return 'Rp ${formatThousandSeparator(value.toInt().toString())}';
  }

  final text = value.toString().trim();
  if (text.isEmpty) {
    return '-';
  }

  if (text.startsWith('Rp')) {
    return text;
  }

  final numericOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (numericOnly.isEmpty) {
    return text;
  }

  return 'Rp ${formatThousandSeparator(numericOnly)}';
}

String formatThousandSeparator(String digits) {
  return digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
}

String formatMonthLabel(String value, {int? year, int? monthNumber}) {
  final resolvedMonth = monthNumber ?? _parseMonthNumber(value);
  if (resolvedMonth >= 1 && resolvedMonth <= 12) {
    final monthName = _monthName(resolvedMonth);
    if (year != null) {
      return '$monthName $year';
    }
    return monthName;
  }

  final normalized = value.trim();
  if (normalized.isEmpty) {
    return '-';
  }
  return normalized;
}

String normalizeStatus(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.contains('verif') || normalized.contains('success') || normalized.contains('paid')) {
    return 'Terverifikasi';
  }
  if (normalized.contains('pending') || normalized.contains('proses') || normalized.contains('waiting')) {
    return 'Menunggu';
  }
  if (normalized.contains('fail') || normalized.contains('reject') || normalized.contains('gagal')) {
    return 'Gagal';
  }
  return value;
}

Color statusColor(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized == 'terverifikasi') {
    return TenantColors.primary;
  }
  if (normalized == 'menunggu') {
    return const Color(0xFF8A3E00);
  }
  if (normalized == 'gagal') {
    return TenantColors.error;
  }
  return TenantColors.primary;
}

String _resolveDioMessage(DioException e) {
  String message = 'Terjadi kesalahan saat upload';
  final errorText = e.error?.toString() ?? '';

  if (errorText.contains('XMLHttpRequest') || errorText.contains('onError')) {
    return 'Gagal terhubung ke server. Cek CORS, URL backend, atau status backend.';
  }

  if (e.response != null) {
    final data = e.response?.data;
    if (data is Map) {
      final validationErrors = data['errors'];
      if (validationErrors is Map && validationErrors.isNotEmpty) {
        final firstEntry = validationErrors.entries.first;
        final firstValue = firstEntry.value;
        if (firstValue is List && firstValue.isNotEmpty) {
          message = firstValue.first.toString();
        } else {
          message = firstValue.toString();
        }
      } else {
        message = data['message']?.toString() ??
            data['error']?.toString() ??
            data['detail']?.toString() ??
            message;
      }
    } else if (data is String) {
      message = data;
    }
    final statusCode = e.response?.statusCode;
    if (statusCode != null) {
      message = 'Upload gagal ($statusCode): $message';
    }
  } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
    message = 'Koneksi terputus (Timeout)';
  } else if ((e.message ?? '').isNotEmpty) {
    message = e.message!;
  }
  return message;
}

double _fontScale(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w < 360) return 0.82;
  if (w < 600) return 0.90;
  if (w < 900) return 0.96;
  return 1.0;
}
