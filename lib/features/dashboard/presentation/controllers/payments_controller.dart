import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';

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

      return PaymentVerificationItem(
        paymentId: paymentId,
        no: _formatIndex(index + 1),
        initials: _buildInitials(tenantName.isEmpty ? roomCode : tenantName),
        tenantName: tenantName.isEmpty ? '-' : tenantName,
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

  Future<void> exportPaymentsDummy({
    PaymentFilterStatus status = PaymentFilterStatus.all,
  }) async {
    final response = await _apiService.get(
      '/api/payments/payment-verify/export-dummy',
      queryParameters: {'status': status.queryParam ?? 'all', 'dummy': 'true'},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final isSuccess = data['success'];
      if (isSuccess is bool && !isSuccess) {
        final message = _asString(data['message']);
        throw Exception(
          message.isEmpty ? 'Gagal mengekspor data pembayaran.' : message,
        );
      }
    }
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
  final String unit;
  final String month;
  final String amount;
  final String date;
  final PaymentVerificationStatus status;
  final int avatarColorKey;
  final String? proofFileUrl;
  final String? proofFileName;

  const PaymentVerificationItem({
    required this.paymentId,
    required this.no,
    required this.initials,
    required this.tenantName,
    required this.unit,
    required this.month,
    required this.amount,
    required this.date,
    required this.status,
    required this.avatarColorKey,
    this.proofFileUrl,
    this.proofFileName,
  });

  factory PaymentVerificationItem.empty({required int index}) {
    return PaymentVerificationItem(
      paymentId: '',
      no: index < 9 ? '0${index + 1}' : '${index + 1}',
      initials: '--',
      tenantName: '-',
      unit: '-',
      month: '-',
      amount: '-',
      date: '-',
      status: PaymentVerificationStatus.pending,
      avatarColorKey: 0,
      proofFileUrl: null,
      proofFileName: null,
    );
  }

  PaymentVerificationItem copyWith({
    String? paymentId,
    String? no,
    String? initials,
    String? tenantName,
    String? unit,
    String? month,
    String? amount,
    String? date,
    PaymentVerificationStatus? status,
    int? avatarColorKey,
    String? proofFileUrl,
    String? proofFileName,
  }) {
    return PaymentVerificationItem(
      paymentId: paymentId ?? this.paymentId,
      no: no ?? this.no,
      initials: initials ?? this.initials,
      tenantName: tenantName ?? this.tenantName,
      unit: unit ?? this.unit,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      avatarColorKey: avatarColorKey ?? this.avatarColorKey,
      proofFileUrl: proofFileUrl ?? this.proofFileUrl,
      proofFileName: proofFileName ?? this.proofFileName,
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
