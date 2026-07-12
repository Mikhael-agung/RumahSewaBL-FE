import 'package:flutter/foundation.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import '../models/activity_log_model.dart';

abstract class ActivityLogRemoteDataSource {
  Future<ActivityLogPageModel> getActivityLogs({int page = 1});
  Future<ActivityLogModel> getActivityLogDetail(int id);
}

class ActivityLogRemoteDataSourceImpl implements ActivityLogRemoteDataSource {
  final ApiService apiService;

  ActivityLogRemoteDataSourceImpl({required this.apiService});

  @override
  Future<ActivityLogPageModel> getActivityLogs({int page = 1}) async {
    try {
      final response = await apiService.get(
        '/api/activity-logs',
        queryParameters: {'page': page},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ActivityLogPageModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get activity logs');
      }
    } catch (e) {
      debugPrint(
        "API Error when fetching activity logs: $e. Returning empty page.",
      );
      return const ActivityLogPageModel(
        items: [],
        currentPage: 1,
        lastPage: 1,
        total: 0,
        perPage: 10,
      );
    }
  }

  @override
  Future<ActivityLogModel> getActivityLogDetail(int id) async {
    final response = await apiService.get('/api/activity-logs/$id');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['data'] ?? response.data;
      return ActivityLogModel.fromJson(data);
    } else {
      throw Exception(
        response.data['message'] ?? 'Failed to get activity log detail',
      );
    }
  }
}