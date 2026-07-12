import '../../entities/activity_log.dart';
import '../../repositories/activity_log_repository.dart';

class GetActivityLogDetailUseCase {
  final ActivityLogRepository repository;

  GetActivityLogDetailUseCase(this.repository);

  Future<ActivityLog> execute(int id) {
    return repository.getActivityLogDetail(id);
  }
}