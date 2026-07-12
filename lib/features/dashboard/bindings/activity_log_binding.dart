import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import '../data/datasources/activity_log_remote_data_source.dart';
import '../data/repositories/activity_log_repository_impl.dart' hide ActivityLogRemoteDataSource, ActivityLogRemoteDataSourceImpl;
import '../domain/repositories/activity_log_repository.dart';
import '../domain/usecases/activity_log/get_activity_logs_usecase.dart';
import '../domain/usecases/activity_log/get_activity_log_detail_usecase.dart';
import '../presentation/controllers/activity_log_controller.dart';

class ActivityLogBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<Dio>()) {
      Get.lazyPut<Dio>(() => Dio());
    }

    Get.lazyPut<ActivityLogRemoteDataSource>(
      () => ActivityLogRemoteDataSourceImpl(apiService: Get.find<ApiService>()),
    );

    Get.lazyPut<ActivityLogRepository>(
      () => ActivityLogRepositoryImpl(remoteDataSource: Get.find()),
    );

    Get.lazyPut<GetActivityLogsUseCase>(
      () => GetActivityLogsUseCase(Get.find<ActivityLogRepository>()),
    );

    Get.lazyPut<GetActivityLogDetailUseCase>(
      () => GetActivityLogDetailUseCase(Get.find<ActivityLogRepository>()),
    );

    Get.lazyPut<ActivityLogController>(
      () => ActivityLogController(
        getActivityLogsUseCase: Get.find<GetActivityLogsUseCase>(),
        getActivityLogDetailUseCase: Get.find<GetActivityLogDetailUseCase>(),
      ),
    );
  }
}