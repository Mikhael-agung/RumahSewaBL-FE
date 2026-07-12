import '../../domain/entities/activity_log.dart';

class ActivityLogUserModel extends ActivityLogUser {
  const ActivityLogUserModel({required super.id, required super.username});

  factory ActivityLogUserModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogUserModel(
      id: json['id'] ?? 0,
      // Fallback ke 'name' cuma jaga-jaga kalau suatu saat field berubah;
      // sumber utamanya tetap kolom `username` di tabel users.
      username: json['username'] ?? json['name'] ?? 'Tidak diketahui',
    );
  }
}

class ActivityLogModel extends ActivityLog {
  const ActivityLogModel({
    required super.id,
    required super.userId,
    required super.activityType,
    required super.activityDescription,
    required super.ipAddress,
    required super.userAgent,
    required super.createdAt,
    required super.user,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return ActivityLogModel(
      id: json['id'] ?? 0,
      userId: json['user_id'],
      activityType: json['activity_type'] ?? 'unknown',
      activityDescription: json['activity_description'] ?? '',
      ipAddress: json['ip_address'],
      userAgent: json['user_agent'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      user: userJson is Map<String, dynamic>
          ? ActivityLogUserModel.fromJson(userJson)
          : null,
    );
  }
}

/// Parsing response paginator Laravel:
/// `{ success, data: { data: [...], current_page, last_page, total, per_page } }`
class ActivityLogPageModel extends ActivityLogPage {
  const ActivityLogPageModel({
    required super.items,
    required super.currentPage,
    required super.lastPage,
    required super.total,
    required super.perPage,
  });

  factory ActivityLogPageModel.fromJson(Map<String, dynamic> json) {
    final paginator = json['data'] ?? json;
    final List<dynamic> rows = paginator['data'] ?? [];
    return ActivityLogPageModel(
      items: rows
          .map((row) => ActivityLogModel.fromJson(row as Map<String, dynamic>))
          .toList(),
      currentPage: paginator['current_page'] ?? 1,
      lastPage: paginator['last_page'] ?? 1,
      total: paginator['total'] ?? rows.length,
      perPage: paginator['per_page'] ?? 10,
    );
  }
}