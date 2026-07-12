import 'dart:developer';
import 'package:get/get.dart';
import '../../domain/entities/activity_log.dart';
import '../../domain/usecases/activity_log/get_activity_logs_usecase.dart';
import '../../domain/usecases/activity_log/get_activity_log_detail_usecase.dart';

/// Kategori filter di UI. BE tidak punya endpoint search/filter
/// (`ActivityLogController::index()` selalu manggil `getAll()` tanpa baca
/// request), jadi search & filter di sini cuma jalan di data yang lagi
/// ke-load di halaman aktif (client-side), bukan across seluruh dataset.
enum ActivityLogFilter { all, auth, payment, system }

class ActivityLogController extends GetxController {
  final GetActivityLogsUseCase? getActivityLogsUseCase;
  final GetActivityLogDetailUseCase? getActivityLogDetailUseCase;

  ActivityLogController({
    this.getActivityLogsUseCase,
    this.getActivityLogDetailUseCase,
  });

  var isLoading = true.obs;
  var logs = <ActivityLog>[].obs;
  var filteredLogs = <ActivityLog>[].obs;
  var searchQuery = ''.obs;
  var activeFilter = ActivityLogFilter.all.obs;

  var currentPage = 1.obs;
  var lastPage = 1.obs;
  var total = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivityLogs(page: 1);
  }

  static const _authTypes = {'login', 'logout', 'change_password'};
  static const _paymentTypes = {
    'upload_payment',
    'input_manual_payment',
    'verify_payment',
    'update_payment',
    'download_payment_proof',
    'download_invoice',
    'export_payment_report',
    'create_payment_deadline',
    'update_payment_deadline',
  };

  Future<void> fetchActivityLogs({int page = 1}) async {
    try {
      isLoading.value = true;
      if (getActivityLogsUseCase != null) {
        final result = await getActivityLogsUseCase!.execute(page: page);
        logs.assignAll(result.items);
        currentPage.value = result.currentPage;
        lastPage.value = result.lastPage;
        total.value = result.total;
      }
      _applyFilters();
    } catch (e) {
      log("Error fetching activity logs: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToPage(int page) async {
    if (page < 1 || page > lastPage.value || page == currentPage.value) {
      return;
    }
    await fetchActivityLogs(page: page);
  }

  Future<void> refresh() => fetchActivityLogs(page: currentPage.value);

  void search(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void setFilter(ActivityLogFilter filter) {
    activeFilter.value = filter;
    _applyFilters();
  }

  void _applyFilters() {
    Iterable<ActivityLog> result = logs;

    switch (activeFilter.value) {
      case ActivityLogFilter.auth:
        result = result.where((l) => _authTypes.contains(l.activityType));
        break;
      case ActivityLogFilter.payment:
        result = result.where((l) => _paymentTypes.contains(l.activityType));
        break;
      case ActivityLogFilter.system:
        result = result.where(
          (l) => !_authTypes.contains(l.activityType) &&
              !_paymentTypes.contains(l.activityType),
        );
        break;
      case ActivityLogFilter.all:
        break;
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where(
        (l) =>
            (l.user?.username.toLowerCase().contains(query) ?? false) ||
            l.activityType.toLowerCase().contains(query) ||
            l.activityDescription.toLowerCase().contains(query),
      );
    }

    filteredLogs.assignAll(result);
  }

  Future<ActivityLog> getActivityLogDetail(int id) async {
    try {
      if (getActivityLogDetailUseCase != null) {
        return await getActivityLogDetailUseCase!.execute(id);
      }
    } catch (e) {
      log("Error fetching activity log detail: $e");
    }

    final local = logs.firstWhereOrNull((l) => l.id == id);
    if (local != null) return local;

    throw Exception("Activity log dengan id $id tidak ditemukan");
  }
}