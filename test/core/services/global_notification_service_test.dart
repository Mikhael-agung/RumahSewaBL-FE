import 'package:flutter_test/flutter_test.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/global_notification_service.dart';

void main() {
  group('NotificationPayloadParser', () {
    test('parses paginated payload from map.data.data list', () {
      final payload = {
        'success': true,
        'data': {
          'current_page': 2,
          'last_page': 4,
          'total': 25,
          'data': [
            {
              'id': 10,
              'title': 'Tagihan Baru',
              'message': 'Tagihan bulan ini tersedia',
              'is_read': false,
              'created_at': '2026-07-06T10:00:00Z',
            },
          ],
        },
      };

      final result = NotificationPayloadParser.parsePage(payload);

      expect(result.items, hasLength(1));
      expect(result.currentPage, 2);
      expect(result.lastPage, 4);
      expect(result.total, 25);
      expect(result.items.first.id, '10');
      expect(result.items.first.title, 'Tagihan Baru');
      expect(result.items.first.message, 'Tagihan bulan ini tersedia');
      expect(result.items.first.isRead, isFalse);
    });

    test('supports payload as plain list', () {
      final payload = [
        {
          'id': 'notif-1',
          'title': 'Pembayaran diverifikasi',
          'type': 'verifikasi',
          'message': 'Pembayaran telah diverifikasi',
          'is_read': true,
        },
      ];

      final result = NotificationPayloadParser.parsePage(payload);

      expect(result.items, hasLength(1));
      expect(result.currentPage, 1);
      expect(result.lastPage, 1);
      expect(result.items.first.id, 'notif-1');
      expect(result.items.first.type, 'verifikasi');
      expect(result.items.first.isRead, isTrue);
    });

    test('ignores invalid items and empty ids', () {
      final payload = {
        'data': {
          'data': [
            {'id': null, 'message': 'x'},
            {'foo': 'bar'},
          ],
        },
      };

      final result = NotificationPayloadParser.parsePage(payload);
      expect(result.items, isEmpty);
    });
  });

  group('NotificationDedupeCache', () {
    test('returns only unseen notifications and marks them as seen', () {
      final cache = NotificationDedupeCache(maxEntries: 3);
      cache.loadSeenIds(const ['1']);

      final incoming = [
        AppNotificationItem(
          id: '1',
          title: '',
          type: 'upload',
          message: 'lama',
          isRead: true,
        ),
        AppNotificationItem(
          id: '2',
          title: '',
          type: 'reject',
          message: 'baru 1',
          isRead: false,
        ),
        AppNotificationItem(
          id: '3',
          title: '',
          type: 'verifikasi',
          message: 'baru 2',
          isRead: false,
        ),
      ];

      final unseen = cache.filterUnseen(incoming);

      expect(unseen.map((e) => e.id).toList(), ['2', '3']);
      expect(cache.seenIds.toSet(), {'1', '2', '3'});
    });

    test('keeps seen ids bounded by maxEntries', () {
      final cache = NotificationDedupeCache(maxEntries: 2);

      cache.filterUnseen([
        AppNotificationItem(
          id: '1',
          title: '',
          type: 'upload',
          message: 'a',
          isRead: false,
        ),
        AppNotificationItem(
          id: '2',
          title: '',
          type: 'upload',
          message: 'b',
          isRead: false,
        ),
      ]);
      cache.filterUnseen([
        AppNotificationItem(
          id: '3',
          title: '',
          type: 'upload',
          message: 'c',
          isRead: false,
        ),
      ]);

      expect(cache.seenIds.length, 2);
      expect(cache.seenIds, ['2', '3']);
    });
  });
}
