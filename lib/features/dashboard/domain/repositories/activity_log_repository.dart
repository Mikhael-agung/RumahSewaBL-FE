import '../entities/activity_log.dart';

abstract class ActivityLogRepository {
  Future<ActivityLogPage> getActivityLogs({int page = 1});
  Future<ActivityLog> getActivityLogDetail(int id);
}