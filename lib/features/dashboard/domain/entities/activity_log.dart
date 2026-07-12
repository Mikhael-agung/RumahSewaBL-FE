class ActivityLogUser {
  final int id;
  final String username;

  const ActivityLogUser({required this.id, required this.username});
}

class ActivityLog {
  final int id;
  final int? userId;
  final String activityType;
  final String activityDescription;
  final String? ipAddress;
  final String? userAgent;
  final DateTime? createdAt;
  final ActivityLogUser? user;

  const ActivityLog({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.activityDescription,
    required this.ipAddress,
    required this.userAgent,
    required this.createdAt,
    required this.user,
  });
}

class ActivityLogPage {
  final List<ActivityLog> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  const ActivityLogPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  const ActivityLogPage.empty()
    : items = const [],
      currentPage = 1,
      lastPage = 1,
      total = 0,
      perPage = 10;
}
