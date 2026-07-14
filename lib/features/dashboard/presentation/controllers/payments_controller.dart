import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import 'package:rumah_sewa_biru_laut_fe/utils/helpers/export_file_saver_stub.dart'
    if (dart.library.html) 'package:rumah_sewa_biru_laut_fe/utils/helpers/export_file_saver_web.dart'
    as export_file_saver;

class PaymentsRepository {
  final ApiService _apiService;

  PaymentsRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<PaymentVerificationItem>> fetchPayments({
    PaymentFilterStatus status = PaymentFilterStatus.all,
  }) async {
    final response = await _apiService.get(
      '/api/payments/payment-verify',
      queryParameters: status.queryParam == null
          ? null
          : {'status': status.queryParam},
    );
    final raw = response.data;

    final List<dynamic> paymentList;
    if (raw is List) {
      paymentList = raw;
    } else if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      paymentList = data is List ? data : const [];
    } else {
      paymentList = const [];
    }

    return paymentList.asMap().entries.map((entry) {
      final index = entry.key;
      final payment = entry.value;
      if (payment is! Map) {
        return PaymentVerificationItem.empty(index: index);
      }

      final map = payment.cast<String, dynamic>();
      final rental = map['rental'] is Map ? map['rental'] as Map : const {};
      final tenant = rental['tenant'] is Map
          ? rental['tenant'] as Map
          : const {};
      final room = rental['room'] is Map ? rental['room'] as Map : const {};
      final building = room['building'] is Map
          ? room['building'] as Map
          : const {};

      final tenantName = _asString(
        tenant['full_name'] ?? map['tenant_name'] ?? map['created_by_name'],
      );
      final roomCode = _asString(room['room_code'] ?? map['room_code']);
      final buildingName = _asString(building['building_name']);
      final unitLabel = [
        buildingName,
        roomCode,
      ].where((e) => e.isNotEmpty).join(' • ');
      final paymentMonth = _parseInt(map['payment_month']);
      final paymentYear = _parseInt(map['payment_year']);
      final paymentId = _asString(
        map['id_payment'] ?? map['payment_id'] ?? map['id'] ?? map['paymentId'],
      );
      final verifiedAtRaw = _asString(
        map['verified_at'] ??
            map['verification_date'] ??
            map['verification_at'] ??
            map['updated_at'],
      );

      return PaymentVerificationItem(
        paymentId: paymentId,
        no: _formatIndex(index + 1),
        initials: _buildInitials(tenantName.isEmpty ? roomCode : tenantName),
        tenantName: tenantName.isEmpty ? '-' : tenantName,
        tenantCode: _asNullableString(
          tenant['tenant_code'] ?? map['tenant_code'] ?? map['tenantCode'],
        ),
        unit: unitLabel.isEmpty ? '-' : unitLabel,
        month: _formatPeriod(paymentMonth, paymentYear),
        amount: _formatCurrency(map['amount']),
        date: _formatDateLabel(
          _asString(
            map['payment_date'] ?? map['uploaded_at'] ?? map['created_at'],
          ),
        ),
        status: mapPaymentStatus(
          _asString(
            map['payment_status'] ??
                map['status'] ??
                map['verification_status'],
          ),
        ),
        avatarColorKey: _avatarColorKey(tenantName),
        proofFileUrl: _asNullableString(
          map['proof_file_url'] ?? map['proofFileUrl'],
        ),
        proofFileName: _asNullableString(
          map['proof_file_name'] ?? map['proofFileName'],
        ),
        paymentMethod: _asNullableString(
          map['payment_method'] ??
              map['method'] ??
              map['transfer_method'] ??
              map['paymentMethod'],
        ),
        verificationBy: _asNullableString(
          map['verified_by_name'] ??
              map['verified_by'] ??
              map['verifiedBy'] ??
              map['verified_by_user_name'],
        ),
        verifiedAtLabel: verifiedAtRaw.isEmpty
            ? null
            : _formatDateTimeLabel(verifiedAtRaw),
        tenantNote: _asNullableString(
          map['tenant_note'] ??
              map['verification_note'] ??
              map['note'] ??
              map['description'],
        ),
      );
    }).toList();
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required PaymentVerificationStatus status,
    String? rejectionReason,
  }) async {
    if (paymentId.trim().isEmpty) {
      throw Exception('ID pembayaran tidak ditemukan.');
    }

    final body = <String, dynamic>{'status': status.apiValue};
    if (status == PaymentVerificationStatus.rejected) {
      body['rejection_reason'] = (rejectionReason ?? '').trim();
    }

    await _apiService.post('/api/payments/$paymentId/status', data: body);
  }

  Future<PaymentExportResult> exportPayments({
    PaymentExportQuery query = const PaymentExportQuery(),
  }) async {
    final response = await _apiService.get(
      '/api/reports/payments/export',
      queryParameters: query.toQueryParameters(),
    );

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Format respons export pembayaran tidak valid.');
    }

    final payload = response.data as Map<String, dynamic>;
    final isSuccess = payload['success'];
    if (isSuccess is bool && !isSuccess) {
      final message = _asString(payload['message']);
      throw Exception(
        message.isEmpty ? 'Gagal mengekspor data pembayaran.' : message,
      );
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Data export pembayaran tidak ditemukan.');
    }

    final filename = _asString(data['filename']);
    final fileUrl = _asString(data['url']);

    if (fileUrl.isEmpty) {
      throw Exception('URL file export pembayaran tidak tersedia.');
    }

    final fallbackName = filename.isEmpty
        ? 'Laporan-Pembayaran-${DateTime.now().millisecondsSinceEpoch}.xlsx'
        : filename;
    final savedPath = await export_file_saver.saveExportFile(
      url: fileUrl,
      fileName: fallbackName,
    );
    if (savedPath == null) {
      throw Exception('Penyimpanan file dibatalkan.');
    }

    return PaymentExportResult(
      filename: fallbackName,
      sourceUrl: fileUrl,
      savedPath: savedPath,
    );
  }

  Future<PaymentExportFilterOptions> fetchExportFilterOptions() async {
    final results = await Future.wait<dynamic>([
      _safeGet('/api/buildings'),
      _safeGet('/api/rooms'),
      _safeGet('/api/tenants'),
    ]);

    final buildingRawList = _extractList(results[0]);
    final roomRawList = _extractList(results[1]);
    final tenantRawList = _extractList(results[2]);

    return PaymentExportFilterOptions(
      buildings: _parseBuildingOptions(buildingRawList),
      rooms: _parseRoomOptions(roomRawList),
      tenants: _parseTenantOptions(tenantRawList),
    );
  }

  Future<dynamic> _safeGet(String path) async {
    try {
      final response = await _apiService.get(path);
      return response.data;
    } catch (_) {
      return const [];
    }
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) {
      return raw;
    }
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return data;
      }
    }
    return const [];
  }

  List<PaymentExportFilterOption> _parseBuildingOptions(List<dynamic> rawList) {
    return rawList
        .whereType<Map>()
        .map((item) => _normalizeMap(item))
        .map((map) {
          final id = _parseInt(map['id'] ?? map['building_id']);
          final name = _asString(map['building_name'] ?? map['name']);
          final code = _asString(map['building_code'] ?? map['code']);
          final fallbackLabel = id > 0 ? 'Building #$id' : '';
          final label = [
            code,
            name,
          ].where((value) => value.isNotEmpty).join(' • ');
          final finalLabel = label.isEmpty ? fallbackLabel : label;
          if (id <= 0 || finalLabel.isEmpty) {
            return null;
          }
          return PaymentExportFilterOption(id: id, label: finalLabel);
        })
        .whereType<PaymentExportFilterOption>()
        .toList(growable: false);
  }

  List<PaymentExportFilterOption> _parseRoomOptions(List<dynamic> rawList) {
    return rawList
        .whereType<Map>()
        .map((item) => _normalizeMap(item))
        .map((map) {
          final id = _parseInt(map['id'] ?? map['room_id']);
          final roomCode = _asString(map['room_code'] ?? map['code']);
          final buildingRaw = map['building'];
          final buildingMap = buildingRaw is Map
              ? _normalizeMap(buildingRaw)
              : null;
          final buildingName = buildingMap == null
              ? ''
              : _asString(buildingMap['building_name'] ?? buildingMap['name']);
          final fallbackLabel = id > 0 ? 'Room #$id' : '';
          final label = [
            buildingName,
            roomCode,
          ].where((value) => value.isNotEmpty).join(' • ');
          final finalLabel = label.isEmpty ? fallbackLabel : label;
          if (id <= 0 || finalLabel.isEmpty) {
            return null;
          }
          return PaymentExportFilterOption(id: id, label: finalLabel);
        })
        .whereType<PaymentExportFilterOption>()
        .toList(growable: false);
  }

  List<PaymentExportFilterOption> _parseTenantOptions(List<dynamic> rawList) {
    return rawList
        .whereType<Map>()
        .map((item) => _normalizeMap(item))
        .map((map) {
          final id = _parseInt(map['id'] ?? map['tenant_id']);
          final fullName = _asString(map['full_name'] ?? map['name']);
          final tenantCode = _asString(map['tenant_code'] ?? map['code']);
          final fallbackLabel = id > 0 ? 'Tenant #$id' : '';
          final label = [
            fullName,
            tenantCode,
          ].where((value) => value.isNotEmpty).join(' • ');
          final finalLabel = label.isEmpty ? fallbackLabel : label;
          if (id <= 0 || finalLabel.isEmpty) {
            return null;
          }
          return PaymentExportFilterOption(id: id, label: finalLabel);
        })
        .whereType<PaymentExportFilterOption>()
        .toList(growable: false);
  }

  Map<String, dynamic> _normalizeMap(Map raw) {
    final casted = raw.cast<String, dynamic>();
    final nested = casted['data'];
    if (nested is Map) {
      return nested.cast<String, dynamic>();
    }
    return casted;
  }

  String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  String? _asNullableString(dynamic value) {
    final result = _asString(value);
    return result.isEmpty ? null : result;
  }

  int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(_asString(value)) ?? 0;
  }

  String _formatIndex(int value) {
    if (value < 10) {
      return '0$value';
    }
    return value.toString();
  }

  String _buildInitials(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return '--';
    }

    final words = normalized
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return '--';
    }

    if (words.length == 1) {
      final single = words.first;
      if (single.length == 1) {
        return single.toUpperCase();
      }
      return single.substring(0, 2).toUpperCase();
    }

    return (words.first.substring(0, 1) + words.last.substring(0, 1))
        .toUpperCase();
  }

  String _formatPeriod(int month, int year) {
    if (month >= 1 && month <= 12 && year >= 1900) {
      return '${_monthName(month)} $year';
    }
    return '-';
  }

  String _monthName(int month) {
    const monthNames = [
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

    if (month < 1 || month > 12) {
      return '-';
    }
    return monthNames[month - 1];
  }

  String _formatCurrency(dynamic amount) {
    final numeric = _asString(amount).replaceAll(RegExp(r'[^0-9]'), '');
    if (numeric.isEmpty) {
      return '-';
    }

    return 'Rp ${numeric.replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (match) => '.')}';
  }

  String _formatDateLabel(String raw) {
    if (raw.isEmpty) {
      return '-';
    }

    final date = DateTime.tryParse(raw);
    if (date == null) {
      return raw;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTimeLabel(String raw) {
    if (raw.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = parsed.day.toString().padLeft(2, '0');
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$day ${months[parsed.month - 1]} ${parsed.year}, $hour:$minute';
  }

  int _avatarColorKey(String value) {
    if (value.trim().isEmpty) {
      return 0;
    }
    return value.codeUnits.fold(0, (a, b) => a + b).isEven ? 1 : 2;
  }
}

enum PaymentVerificationStatus { pending, verified, rejected }

enum PaymentFilterStatus {
  all,
  pendingVerification,
  verified,
  rejected;

  String? get queryParam {
    switch (this) {
      case PaymentFilterStatus.all:
        return null;
      case PaymentFilterStatus.pendingVerification:
        return 'menunggu_verifikasi';
      case PaymentFilterStatus.verified:
        return 'terverifikasi';
      case PaymentFilterStatus.rejected:
        return 'ditolak';
    }
  }
}

enum PaymentExportStatus {
  all,
  pendingVerification,
  verified,
  rejected;

  String get queryValue {
    switch (this) {
      case PaymentExportStatus.all:
        return 'all';
      case PaymentExportStatus.pendingVerification:
        return 'menunggu_verifikasi';
      case PaymentExportStatus.verified:
        return 'terverifikasi';
      case PaymentExportStatus.rejected:
        return 'ditolak';
    }
  }
}

extension PaymentFilterStatusExport on PaymentFilterStatus {
  PaymentExportStatus get toExportStatus {
    switch (this) {
      case PaymentFilterStatus.all:
        return PaymentExportStatus.all;
      case PaymentFilterStatus.pendingVerification:
        return PaymentExportStatus.pendingVerification;
      case PaymentFilterStatus.verified:
        return PaymentExportStatus.verified;
      case PaymentFilterStatus.rejected:
        return PaymentExportStatus.rejected;
    }
  }
}

class PaymentExportQuery {
  final int? buildingId;
  final String? dateFrom;
  final String? dateTo;
  final int? month;
  final int? roomId;
  final PaymentExportStatus? status;
  final int? tenantId;
  final int? year;

  const PaymentExportQuery({
    this.buildingId,
    this.dateFrom,
    this.dateTo,
    this.month,
    this.roomId,
    this.status,
    this.tenantId,
    this.year,
  });

  Map<String, dynamic>? toQueryParameters() {
    final params = <String, dynamic>{};

    if (buildingId != null) {
      params['building_id'] = buildingId;
    }
    if (dateFrom != null && dateFrom!.trim().isNotEmpty) {
      params['date_from'] = dateFrom;
    }
    if (dateTo != null && dateTo!.trim().isNotEmpty) {
      params['date_to'] = dateTo;
    }
    if (month != null) {
      params['month'] = month;
    }
    if (roomId != null) {
      params['room_id'] = roomId;
    }
    if (status != null) {
      params['status'] = status!.queryValue;
    }
    if (tenantId != null) {
      params['tenant_id'] = tenantId;
    }
    if (year != null) {
      params['year'] = year;
    }

    return params.isEmpty ? null : params;
  }
}

class PaymentExportFilterOption {
  final int id;
  final String label;

  const PaymentExportFilterOption({required this.id, required this.label});
}

class PaymentExportFilterOptions {
  final List<PaymentExportFilterOption> buildings;
  final List<PaymentExportFilterOption> rooms;
  final List<PaymentExportFilterOption> tenants;

  const PaymentExportFilterOptions({
    this.buildings = const <PaymentExportFilterOption>[],
    this.rooms = const <PaymentExportFilterOption>[],
    this.tenants = const <PaymentExportFilterOption>[],
  });
}

class PaymentExportResult {
  final String filename;
  final String sourceUrl;
  final String savedPath;

  const PaymentExportResult({
    required this.filename,
    required this.sourceUrl,
    required this.savedPath,
  });
}

extension PaymentVerificationStatusApi on PaymentVerificationStatus {
  String get apiValue {
    switch (this) {
      case PaymentVerificationStatus.pending:
        return 'menunggu_verifikasi';
      case PaymentVerificationStatus.verified:
        return 'terverifikasi';
      case PaymentVerificationStatus.rejected:
        return 'ditolak';
    }
  }
}

PaymentVerificationStatus mapPaymentStatus(String rawStatus) {
  final normalized = rawStatus.trim().toLowerCase();
  final compacted = normalized.replaceAll(' ', '_');

  if (compacted == 'menunggu_verifikasi' || compacted == 'menunggu') {
    return PaymentVerificationStatus.pending;
  }
  if (compacted == 'terverifikasi' || compacted == 'verified') {
    return PaymentVerificationStatus.verified;
  }
  if (compacted == 'ditolak' || compacted == 'rejected') {
    return PaymentVerificationStatus.rejected;
  }

  if (compacted.contains('tolak') || compacted.contains('reject')) {
    return PaymentVerificationStatus.rejected;
  }
  if (compacted.contains('tunggu')) {
    return PaymentVerificationStatus.pending;
  }
  if (compacted == 'verifikasi' || compacted.contains('verified')) {
    return PaymentVerificationStatus.verified;
  }

  return PaymentVerificationStatus.pending;
}

class PaymentVerificationItem {
  final String paymentId;
  final String no;
  final String initials;
  final String tenantName;
  final String? tenantCode;
  final String unit;
  final String month;
  final String amount;
  final String date;
  final PaymentVerificationStatus status;
  final int avatarColorKey;
  final String? proofFileUrl;
  final String? proofFileName;
  final String? paymentMethod;
  final String? verificationBy;
  final String? verifiedAtLabel;
  final String? tenantNote;

  const PaymentVerificationItem({
    required this.paymentId,
    required this.no,
    required this.initials,
    required this.tenantName,
    this.tenantCode,
    required this.unit,
    required this.month,
    required this.amount,
    required this.date,
    required this.status,
    required this.avatarColorKey,
    this.proofFileUrl,
    this.proofFileName,
    this.paymentMethod,
    this.verificationBy,
    this.verifiedAtLabel,
    this.tenantNote,
  });

  factory PaymentVerificationItem.empty({required int index}) {
    return PaymentVerificationItem(
      paymentId: '',
      no: index < 9 ? '0${index + 1}' : '${index + 1}',
      initials: '--',
      tenantName: '-',
      tenantCode: null,
      unit: '-',
      month: '-',
      amount: '-',
      date: '-',
      status: PaymentVerificationStatus.pending,
      avatarColorKey: 0,
      proofFileUrl: null,
      proofFileName: null,
      paymentMethod: null,
      verificationBy: null,
      verifiedAtLabel: null,
      tenantNote: null,
    );
  }

  PaymentVerificationItem copyWith({
    String? paymentId,
    String? no,
    String? initials,
    String? tenantName,
    String? tenantCode,
    String? unit,
    String? month,
    String? amount,
    String? date,
    PaymentVerificationStatus? status,
    int? avatarColorKey,
    String? proofFileUrl,
    String? proofFileName,
    String? paymentMethod,
    String? verificationBy,
    String? verifiedAtLabel,
    String? tenantNote,
  }) {
    return PaymentVerificationItem(
      paymentId: paymentId ?? this.paymentId,
      no: no ?? this.no,
      initials: initials ?? this.initials,
      tenantName: tenantName ?? this.tenantName,
      tenantCode: tenantCode ?? this.tenantCode,
      unit: unit ?? this.unit,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      avatarColorKey: avatarColorKey ?? this.avatarColorKey,
      proofFileUrl: proofFileUrl ?? this.proofFileUrl,
      proofFileName: proofFileName ?? this.proofFileName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      verificationBy: verificationBy ?? this.verificationBy,
      verifiedAtLabel: verifiedAtLabel ?? this.verifiedAtLabel,
      tenantNote: tenantNote ?? this.tenantNote,
    );
  }
}

String normalizeProofUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) {
    return trimmed;
  }
  return Uri.encodeFull(trimmed);
}

String proofExtension(PaymentVerificationItem entry) {
  String source = entry.proofFileName ?? '';
  if (source.isEmpty && entry.proofFileUrl != null) {
    source = Uri.parse(entry.proofFileUrl!).path;
  }

  final dotIndex = source.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == source.length - 1) {
    return '';
  }
  return source.substring(dotIndex + 1).toLowerCase();
}
