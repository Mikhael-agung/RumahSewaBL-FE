import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../presentation/controllers/login_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Dio instance
    Get.lazyPut<Dio>(() => Dio(BaseOptions(
      baseUrl: 'https://rumahsewabl-be-production.up.railway.app',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    )));

    // Data Sources
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dio: Get.find()),
    );

    // Repositories
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: Get.find()),
    );

    // Use Cases
    Get.lazyPut<LoginUseCase>(
      () => LoginUseCase(Get.find()),
    );

    // Controllers
    Get.lazyPut<LoginController>(
      () => LoginController(loginUseCase: Get.find()),
    );
  }
}
