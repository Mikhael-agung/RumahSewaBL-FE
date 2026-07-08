import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_bloc.dart';

void main() {
  group('isUnauthenticatedMessage', () {
    test('returns true for Unauthenticated message', () {
      expect(isUnauthenticatedMessage('Unauthenticated.'), isTrue);
    });

    test('returns true for missing token message', () {
      expect(isUnauthenticatedMessage('Token login tidak ditemukan'), isTrue);
    });

    test('returns false for non-auth message', () {
      expect(
        isUnauthenticatedMessage('Data pembayaran tidak ditemukan'),
        isFalse,
      );
    });
  });
}
