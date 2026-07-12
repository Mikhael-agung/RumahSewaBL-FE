import '../../entities/activity_log.dart';
import '../../repositories/activity_log_repository.dart';

class GetActivityLogsUseCase {
  final ActivityLogRepository repository;

  GetActivityLogsUseCase(this.repository);

  Future<ActivityLogPage> execute({int page = 1}) {
    return repository.getActivityLogs(page: page);
  }
}