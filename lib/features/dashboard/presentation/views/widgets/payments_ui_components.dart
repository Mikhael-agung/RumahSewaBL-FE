import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/colors.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';
import 'package:rumah_sewa_biru_laut_fe/utils/helpers/currency_format.dart';

class PaymentsHeaderSection extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onExportPressed;
  final bool isExporting;

  const PaymentsHeaderSection({
    super.key,
    required this.isMobile,
    required this.onExportPressed,
    this.isExporting = false,
  });

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
              const SizedBox(height: 14),
              _exportButton(isCompact: true),
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
              const SizedBox(width: 18),
              _exportButton(isCompact: false),
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
      child: InkWell(
        onTap: isExporting ? null : onExportPressed,
        borderRadius: BorderRadius.circular(999),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isExporting) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ] else ...[
              const Icon(
                Icons.file_download_outlined,
                size: 18,
                color: Color(0xFF111827),
              ),
            ],
            const SizedBox(width: 8),
            Text(
              isExporting ? 'Mengekspor...' : 'Ekspor Data',
              style: TextStyle(
                fontSize: isCompact ? 13 : 15,
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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

class PaymentExportFilterDialog extends StatefulWidget {
  final PaymentExportQuery initialQuery;
  final PaymentsRepository? repository;

  const PaymentExportFilterDialog({
    super.key,
    required this.initialQuery,
    this.repository,
  });

  @override
  State<PaymentExportFilterDialog> createState() =>
      _PaymentExportFilterDialogState();
}

class _PaymentExportFilterDialogState extends State<PaymentExportFilterDialog> {
  late final TextEditingController _monthController;
  late final TextEditingController _yearController;
  late final PaymentsRepository _repository;
  bool _isLoadingFilterOptions = true;
  String _filterOptionError = '';
  List<PaymentExportFilterOption> _buildingOptions = const [];
  List<PaymentExportFilterOption> _roomOptions = const [];
  List<PaymentExportFilterOption> _tenantOptions = const [];
  int? _selectedBuildingId;
  int? _selectedRoomId;
  int? _selectedTenantId;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  PaymentExportStatus? _status;

  @override
  void initState() {
    super.initState();
    _monthController = TextEditingController(
      text: _toInputValue(widget.initialQuery.month),
    );
    _yearController = TextEditingController(
      text: _toInputValue(widget.initialQuery.year),
    );
    _repository = widget.repository ?? PaymentsRepository();
    _selectedBuildingId = widget.initialQuery.buildingId;
    _selectedRoomId = widget.initialQuery.roomId;
    _selectedTenantId = widget.initialQuery.tenantId;
    _status = widget.initialQuery.status;
    _dateFrom = _parseDate(widget.initialQuery.dateFrom);
    _dateTo = _parseDate(widget.initialQuery.dateTo);
    _loadFilterOptions();
  }

  @override
  void dispose() {
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.of(context).size.width > 860 ? 760.0 : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth ?? 760),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            color: const Color(0xFFF8FAFD),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 22, 20, 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Filter Ekspor Pembayaran',
                          style: TextStyle(
                            fontSize: 46 / 2,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101828),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        icon: const Icon(Icons.close_rounded, size: 30),
                        color: const Color(0xFF6B7280),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('BUILDING'),
                        const SizedBox(height: 8),
                        _buildApiDropdownField(
                          value: _selectedBuildingId,
                          items: _buildingOptions,
                          allLabel: 'Semua Gedung',
                          onChanged: (value) =>
                              setState(() => _selectedBuildingId = value),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('ROOM'),
                                  const SizedBox(height: 8),
                                  _buildApiDropdownField(
                                    value: _selectedRoomId,
                                    items: _roomOptions,
                                    allLabel: 'Semua Kamar',
                                    onChanged: (value) =>
                                        setState(() => _selectedRoomId = value),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('TENANT'),
                                  const SizedBox(height: 8),
                                  _buildApiDropdownField(
                                    value: _selectedTenantId,
                                    items: _tenantOptions,
                                    allLabel: 'Semua Penyewa',
                                    onChanged: (value) => setState(
                                      () => _selectedTenantId = value,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_filterOptionError.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Color(0xFFB45309),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _filterOptionError,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF92400E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoadingFilterOptions
                                    ? null
                                    : _loadFilterOptions,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('BULAN (1-12)'),
                                  const SizedBox(height: 8),
                                  _buildNumberField(
                                    controller: _monthController,
                                    hintText: '01',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('TAHUN'),
                                  const SizedBox(height: 8),
                                  _buildNumberField(
                                    controller: _yearController,
                                    hintText: '2024',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('STATUS PEMBAYARAN'),
                        const SizedBox(height: 8),
                        _buildStatusDropdownField(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('TANGGAL MULAI'),
                                  const SizedBox(height: 8),
                                  _buildDateField(
                                    value: _dateFrom,
                                    onSelect: (value) {
                                      setState(() => _dateFrom = value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildFieldLabel('TANGGAL AKHIR'),
                                  const SizedBox(height: 8),
                                  _buildDateField(
                                    value: _dateTo,
                                    onSelect: (value) {
                                      setState(() => _dateTo = value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9EDF3),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF0D5C8E),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Semua field opsional. Isi satu atau lebih filter sesuai kebutuhan untuk menghasilkan laporan yang spesifik.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4B5563),
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),
                  decoration: const BoxDecoration(color: Color(0xFFEFF2F7)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontSize: 17,
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        onPressed: _isLoadingFilterOptions ? null : _submit,
                        icon: const Icon(
                          Icons.file_download_outlined,
                          size: 18,
                        ),
                        label: const Text('Ekspor Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005D90),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18 / 1.4,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadFilterOptions() async {
    setState(() {
      _isLoadingFilterOptions = true;
      _filterOptionError = '';
    });

    try {
      final options = await _repository.fetchExportFilterOptions();
      if (!mounted) {
        return;
      }

      setState(() {
        _buildingOptions = options.buildings;
        _roomOptions = options.rooms;
        _tenantOptions = options.tenants;
        _selectedBuildingId = _resolveSelectedValue(
          _selectedBuildingId,
          _buildingOptions,
        );
        _selectedRoomId = _resolveSelectedValue(_selectedRoomId, _roomOptions);
        _selectedTenantId = _resolveSelectedValue(
          _selectedTenantId,
          _tenantOptions,
        );
        _isLoadingFilterOptions = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _buildingOptions = const [];
        _roomOptions = const [];
        _tenantOptions = const [];
        _isLoadingFilterOptions = false;
        _filterOptionError =
            'Gagal memuat daftar Building/Room/Tenant dari API.';
      });
    }
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1F2937),
        fontWeight: FontWeight.w600,
      ),
      decoration: _fieldDecoration(hintText: hintText),
    );
  }

  Widget _buildApiDropdownField({
    required int? value,
    required List<PaymentExportFilterOption> items,
    required String allLabel,
    required ValueChanged<int?> onChanged,
  }) {
    if (_isLoadingFilterOptions) {
      return InputDecorator(
        decoration: _fieldDecoration(
          hintText: 'Memuat data...',
          suffixIcon: const Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        child: const SizedBox.shrink(),
      );
    }

    final validValue = _resolveSelectedValue(value, items);
    return DropdownButtonFormField<int?>(
      initialValue: validValue,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1F2937),
        fontWeight: FontWeight.w600,
      ),
      decoration: _fieldDecoration(),
      items: [
        DropdownMenuItem<int?>(value: null, child: Text(allLabel)),
        ...items.map(
          (item) =>
              DropdownMenuItem<int?>(value: item.id, child: Text(item.label)),
        ),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildStatusDropdownField() {
    return DropdownButtonFormField<PaymentExportStatus?>(
      initialValue: _status,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1F2937),
        fontWeight: FontWeight.w600,
      ),
      decoration: _fieldDecoration(),
      items: const [
        DropdownMenuItem<PaymentExportStatus?>(
          value: null,
          child: Text('Semua Status'),
        ),
        DropdownMenuItem<PaymentExportStatus?>(
          value: PaymentExportStatus.all,
          child: Text('Semua Status (all)'),
        ),
        DropdownMenuItem<PaymentExportStatus?>(
          value: PaymentExportStatus.pendingVerification,
          child: Text('Menunggu Verifikasi'),
        ),
        DropdownMenuItem<PaymentExportStatus?>(
          value: PaymentExportStatus.verified,
          child: Text('Terverifikasi'),
        ),
        DropdownMenuItem<PaymentExportStatus?>(
          value: PaymentExportStatus.rejected,
          child: Text('Ditolak'),
        ),
      ],
      onChanged: (value) => setState(() => _status = value),
    );
  }

  Widget _buildDateField({
    required DateTime? value,
    required ValueChanged<DateTime?> onSelect,
  }) {
    final formatter = DateFormat('dd/MM/yyyy');
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (!mounted) {
          return;
        }
        onSelect(picked);
      },
      child: InputDecorator(
        decoration: _fieldDecoration(
          hintText: 'dd/mm/yyyy',
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            size: 20,
            color: Color(0xFF1F2937),
          ),
        ),
        child: Text(
          value == null ? 'dd/mm/yyyy' : formatter.format(value),
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _submit() {
    final month = _parseIntField(_monthController.text, 'Bulan');
    final year = _parseIntField(_yearController.text, 'Tahun');

    if (month == null || year == null) {
      return;
    }

    if (month != -1 && (month < 1 || month > 12)) {
      _showValidationError('Bulan harus di antara 1 sampai 12.');
      return;
    }
    if (year != -1 && (year < 2000 || year > 2100)) {
      _showValidationError('Tahun harus di antara 2000 sampai 2100.');
      return;
    }
    if (_dateFrom != null && _dateTo != null && _dateFrom!.isAfter(_dateTo!)) {
      _showValidationError(
        'Tanggal mulai tidak boleh lebih besar dari tanggal akhir.',
      );
      return;
    }

    final query = PaymentExportQuery(
      buildingId: _selectedBuildingId,
      month: month == -1 ? null : month,
      roomId: _selectedRoomId,
      tenantId: _selectedTenantId,
      year: year == -1 ? null : year,
      status: _status,
      dateFrom: _dateFrom?.toIso8601String(),
      dateTo: _dateTo == null
          ? null
          : DateTime(
              _dateTo!.year,
              _dateTo!.month,
              _dateTo!.day,
              23,
              59,
              59,
            ).toIso8601String(),
    );

    Navigator.of(context).pop(query);
  }

  int? _parseIntField(String raw, String fieldLabel) {
    final value = raw.trim();
    if (value.isEmpty) {
      return -1;
    }

    final parsed = int.tryParse(value);
    if (parsed == null) {
      _showValidationError('$fieldLabel harus berupa angka.');
      return null;
    }
    return parsed;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _toInputValue(int? value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  int? _resolveSelectedValue(
    int? value,
    List<PaymentExportFilterOption> items,
  ) {
    if (value == null) {
      return null;
    }
    final hasMatch = items.any((item) => item.id == value);
    return hasMatch ? value : null;
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF0B4C7A),
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFD8E5F9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: Color(0xFF9DB8E8), width: 1.2),
      ),
    );
  }
}

class PaymentDesktopTable extends StatelessWidget {
  final List<PaymentVerificationItem> entries;
  final VoidCallback onReload;
  final ValueChanged<PaymentVerificationItem> onShowProofFile;
  final ValueChanged<PaymentVerificationItem> onVerifyPayment;
  final ValueChanged<PaymentVerificationItem> onRejectPayment;
  final Set<String> verifyingPaymentIds;

  const PaymentDesktopTable({
    super.key,
    required this.entries,
    required this.onReload,
    required this.onShowProofFile,
    required this.onVerifyPayment,
    required this.onRejectPayment,
    required this.verifyingPaymentIds,
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
                onVerify: () => onVerifyPayment(entry),
                onReject: () => onRejectPayment(entry),
                isVerifying: verifyingPaymentIds.contains(entry.paymentId),
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
  final ValueChanged<PaymentVerificationItem> onVerifyPayment;
  final ValueChanged<PaymentVerificationItem> onRejectPayment;
  final Set<String> verifyingPaymentIds;

  const PaymentMobileList({
    super.key,
    required this.entries,
    required this.onReload,
    required this.onVerifyPayment,
    required this.onRejectPayment,
    required this.verifyingPaymentIds,
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
                  child: PaymentActionWidget(
                    status: entry.status,
                    onVerify: () => onVerifyPayment(entry),
                    onReject: () => onRejectPayment(entry),
                    isVerifying: verifyingPaymentIds.contains(entry.paymentId),
                  ),
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
  final VoidCallback? onVerify;
  final VoidCallback? onReject;
  final bool isVerifying;

  const PaymentActionWidget({
    super.key,
    required this.status,
    this.onViewImage,
    this.onVerify,
    this.onReject,
    this.isVerifying = false,
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
            onTap: isVerifying ? null : onVerify,
            isLoading: isVerifying,
          ),
          const SizedBox(width: 8),
          PaymentActionButton(
            label: 'Tolak',
            backgroundColor: const Color(0xFFFFF1F2),
            textColor: const Color(0xFFDC2626),
            borderColor: const Color(0xFFFECACA),
            onTap: isVerifying ? null : onReject,
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
  final VoidCallback? onTap;
  final bool isLoading;

  const PaymentActionButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null || isLoading;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? backgroundColor.withValues(alpha: 0.75)
              : backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(textColor),
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
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
