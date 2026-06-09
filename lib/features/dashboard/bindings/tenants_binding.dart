import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import '../data/datasources/tenants_remote_data_source.dart';
import '../data/repositories/tenants_repository_impl.dart';
import '../domain/repositories/tenants_repository.dart';
import '../domain/usecases/tenants/get_tenants_usecase.dart';
import '../domain/usecases/tenants/add_tenant_usecase.dart';
import '../domain/usecases/tenants/update_tenant_usecase.dart';
import '../domain/usecases/tenants/delete_tenant_usecase.dart';
import '../presentation/controllers/tenants_controller.dart';

class TenantsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<Dio>()) {
      Get.lazyPut<Dio>(() => Dio());
    }

    Get.lazyPut<TenantsRemoteDataSource>(
      () => TenantsRemoteDataSourceImpl(apiService: Get.find<ApiService>()),
    );

    Get.lazyPut<TenantsRepository>(
      () => TenantsRepositoryImpl(remoteDataSource: Get.find()),
    );

    Get.lazyPut<GetTenantsUseCase>(
      () => GetTenantsUseCase(Get.find<TenantsRepository>()),
    );

    Get.lazyPut<AddTenantUseCase>(
      () => AddTenantUseCase(Get.find<TenantsRepository>()),
    );

    Get.lazyPut<UpdateTenantUseCase>(
      () => UpdateTenantUseCase(Get.find<TenantsRepository>()),
    );

    Get.lazyPut<DeleteTenantUseCase>(
      () => DeleteTenantUseCase(Get.find<TenantsRepository>()),
    );

    Get.lazyPut<TenantsController>(
      () => TenantsController(
        getTenantsUseCase: Get.find<GetTenantsUseCase>(),
        addTenantUseCase: Get.find<AddTenantUseCase>(),
        updateTenantUseCase: Get.find<UpdateTenantUseCase>(),
        deleteTenantUseCase: Get.find<DeleteTenantUseCase>(),
      ),
    );
  }
}
