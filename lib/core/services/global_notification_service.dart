import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';

class AppNotificationItem {
  final String id;
  final String title;
  final String type;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.type,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  AppNotificationItem copyWith({bool? isRead}) {
    return AppNotificationItem(
      id: id,
      title: title,
      type: type,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawTitle = json['title'];
    final rawType = json['type'];
    final rawMessage = json['message'];
    final rawIsRead = json['is_read'] ?? json['isRead'];
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];

    DateTime? parsedCreatedAt;
    if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt);
    }

    final isRead = rawIsRead == true || rawIsRead == 1 || rawIsRead == '1';

    return AppNotificationItem(
      id: rawId?.toString() ?? '',
      title: rawTitle?.toString() ?? '',
      type: rawType?.toString() ?? '',
      message: rawMessage?.toString() ?? '',
      isRead: isRead,
      createdAt: parsedCreatedAt,
    );
  }
}

class NotificationPageResult {
  final List<AppNotificationItem> items;
  final int currentPage;
  final int lastPage;
  final int total;

  const NotificationPageResult({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class NotificationPayloadParser {
  static NotificationPageResult parsePage(dynamic payload) {
    if (payload is! Map) {
      final items = _parseItems(payload is List ? payload : const []);
      return NotificationPageResult(
        items: items,
        currentPage: 1,
        lastPage: 1,
        total: items.length,
      );
    }

    final map = Map<String, dynamic>.from(payload);
    final envelope = map['data'];

    if (envelope is Map) {
      final dataMap = Map<String, dynamic>.from(envelope);
      final items = _parseItems(dataMap['data']);
      return NotificationPageResult(
        items: items,
        currentPage: _toInt(dataMap['current_page']) ?? 1,
        lastPage: _toInt(dataMap['last_page']) ?? 1,
        total: _toInt(dataMap['total']) ?? items.length,
      );
    }

    final items = _parseItems(map['data'] ?? map['notifications']);
    return NotificationPageResult(
      items: items,
      currentPage: 1,
      lastPage: 1,
      total: items.length,
    );
  }

  static List<AppNotificationItem> _parseItems(dynamic rawItems) {
    if (rawItems is! List) return const [];

    final notifications = <AppNotificationItem>[];
    for (final item in rawItems) {
      if (item is! Map) continue;
      final casted = Map<String, dynamic>.from(item);
      final notification = AppNotificationItem.fromJson(casted);
      if (notification.id.isEmpty) continue;
      notifications.add(notification);
    }

    return notifications;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class NotificationDedupeCache {
  final int maxEntries;
  final List<String> _seenIds = [];

  NotificationDedupeCache({this.maxEntries = 300});

  List<String> get seenIds => List<String>.unmodifiable(_seenIds);

  void loadSeenIds(List<String> ids) {
    _seenIds
      ..clear()
      ..addAll(ids.where((id) => id.isNotEmpty));
    _shrinkToLimit();
  }

  List<AppNotificationItem> filterUnseen(List<AppNotificationItem> incoming) {
    final unseen = <AppNotificationItem>[];

    for (final item in incoming) {
      if (_seenIds.contains(item.id)) {
        continue;
      }
      unseen.add(item);
      _seenIds.add(item.id);
      _shrinkToLimit();
    }

    return unseen;
  }

  void _shrinkToLimit() {
    while (_seenIds.length > maxEntries) {
      _seenIds.removeAt(0);
    }
  }
}

class GlobalNotificationService extends GetxService
    with WidgetsBindingObserver {
  static const _seenIdsStorageKey = 'notification_seen_ids';
  static const _defaultPerPage = 10;

  final ApiService _apiService = Get.find<ApiService>();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationDedupeCache _dedupeCache = NotificationDedupeCache(
    maxEntries: 300,
  );

  final RxList<AppNotificationItem> notifications = <AppNotificationItem>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalItems = 0.obs;
  final RxBool isLoadingMore = false.obs;

  bool get hasNextPage => currentPage.value < lastPage.value;

  Timer? _pollingTimer;
  bool _initialized = false;
  bool _isPolling = false;
  bool _isForeground = true;
  bool _isRequestInFlight = false;

  Future<GlobalNotificationService> initialize() async {
    if (_initialized) return this;

    WidgetsBinding.instance.addObserver(this);
    await _initializeLocalNotifications();
    await _loadSeenIds();
    _initialized = true;
    await _syncPollingState();
    return this;
  }

  Future<void> startPolling() async {
    if (!_initialized) {
      await initialize();
    }

    if (_isPolling || !_isForeground) return;
    if (!await _hasToken()) return;

    _isPolling = true;
    await _pollNotifications();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _pollNotifications(),
    );
  }

  Future<void> stopPolling({bool clearState = false}) async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;

    if (clearState) {
      notifications.clear();
      unreadCount.value = 0;
      currentPage.value = 1;
      lastPage.value = 1;
      totalItems.value = 0;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshNow() async {
    await _pollNotifications();
  }

  Future<void> loadMore() async {
    if (!hasNextPage || isLoadingMore.value || _isRequestInFlight) return;

    isLoadingMore.value = true;
    try {
      await _fetchNotificationsPage(
        page: currentPage.value + 1,
        append: true,
        showLocalNotification: false,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  void markAllAsRead() {
    final updated = notifications
        .map((item) => item.isRead ? item : item.copyWith(isRead: true))
        .toList();
    notifications.assignAll(updated);
    unreadCount.value = 0;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isForeground = true;
        startPolling();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _isForeground = false;
        stopPolling();
        break;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.onClose();
  }

  Future<void> _syncPollingState() async {
    if (await _hasToken()) {
      await startPolling();
    } else {
      await stopPolling(clearState: true);
    }
  }

  Future<void> _pollNotifications() async {
    if (_isRequestInFlight || !_isForeground) return;

    if (!await _hasToken()) {
      await stopPolling(clearState: true);
      return;
    }

    await _fetchNotificationsPage(
      page: 1,
      append: false,
      showLocalNotification: true,
    );
  }

  Future<void> _fetchNotificationsPage({
    required int page,
    required bool append,
    required bool showLocalNotification,
  }) async {
    _isRequestInFlight = true;
    try {
      final response = await _apiService.get(
        '/api/notifications',
        queryParameters: {'page': page, 'per_page': _defaultPerPage},
      );
      final parsed = NotificationPayloadParser.parsePage(response.data);

      if (append) {
        notifications.addAll(parsed.items);
      } else {
        notifications.assignAll(parsed.items);
      }

      currentPage.value = parsed.currentPage;
      lastPage.value = parsed.lastPage;
      totalItems.value = parsed.total;
      unreadCount.value = notifications.where((item) => !item.isRead).length;

      if (showLocalNotification) {
        final unseen = _dedupeCache.filterUnseen(
          parsed.items.where((item) => !item.isRead).toList(),
        );
        if (unseen.isNotEmpty) {
          for (final notification in unseen.reversed) {
            await _showLocalNotification(notification);
          }
          await _persistSeenIds();
        }
      }
    } catch (_) {
      // Keep silent to avoid notification spam on intermittent network errors.
    } finally {
      _isRequestInFlight = false;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidInitialization = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosInitialization = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
      macOS: iosInitialization,
    );

    await _localNotifications.initialize(settings);
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _showLocalNotification(AppNotificationItem item) async {
    const androidDetails = AndroidNotificationDetails(
      'global_local_notification_channel',
      'Global Local Notifications',
      channelDescription: 'Notifikasi global dari polling endpoint',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _localNotifications.show(
      item.id.hashCode,
      _titleForType(item),
      item.message.isNotEmpty ? item.message : 'Anda memiliki notifikasi baru',
      details,
    );
  }

  String _titleForType(AppNotificationItem item) {
    if (item.title.trim().isNotEmpty) {
      return item.title;
    }

    switch (item.type.trim().toLowerCase()) {
      case 'upload':
        return 'Upload Baru';
      case 'verifikasi':
        return 'Verifikasi Berhasil';
      case 'reject':
        return 'Pengajuan Ditolak';
      default:
        return 'Notifikasi Baru';
    }
  }

  Future<bool> _hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return token.isNotEmpty;
  }

  Future<void> _loadSeenIds() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_seenIdsStorageKey) ?? const <String>[];
    _dedupeCache.loadSeenIds(saved);
  }

  Future<void> _persistSeenIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenIdsStorageKey, _dedupeCache.seenIds);
  }
}
