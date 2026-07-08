import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';

void main() {
  group('PaymentVerificationStatusApi', () {
    test('maps rejected enum to ditolak payload value', () {
      expect(PaymentVerificationStatus.rejected.apiValue, 'ditolak');
    });
  });

  group('mapPaymentStatus', () {
    test('maps menunggu_verifikasi to pending', () {
      expect(
        mapPaymentStatus('menunggu_verifikasi'),
        PaymentVerificationStatus.pending,
      );
    });

    test('maps terverifikasi to verified', () {
      expect(
        mapPaymentStatus('terverifikasi'),
        PaymentVerificationStatus.verified,
      );
    });

    test('maps ditolak to rejected', () {
      expect(mapPaymentStatus('ditolak'), PaymentVerificationStatus.rejected);
    });
  });
}
