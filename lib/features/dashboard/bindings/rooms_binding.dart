import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/data/datasources/rooms_remote_data_source.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/data/repositories/rooms_repository_impl.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/repositories/rooms_repository.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/usecases/rooms/add_rooms_usecase.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/usecases/rooms/delete_rooms_usecase.dart';

class RoomsBinding extends Bindings {
  @override
  void dependencies() {
    // If Dio is not already put globally, register a fallback
    if (!Get.isRegistered<Dio>()) {
      Get.lazyPut<Dio>(() => Dio());
    }

    Get.lazyPut<RoomsRemoteDataSource>(
      () => RoomsRemoteDataSourceImpl(apiService: Get.find<ApiService>()),
    );

    Get.lazyPut<RoomsRepository>(
      () => RoomsRepositoryImpl(remoteDataSource: Get.find()),
    );

    Get.lazyPut<AddRoomsUseCase>(
      () => AddRoomsUseCase(Get.find<RoomsRepository>()),
    );

    Get.lazyPut<DeleteRoomsUseCase>(
      () => DeleteRoomsUseCase(Get.find<RoomsRepository>()),
    );

    // Get.lazyPut<PropertiesController>(
    //   () => PropertiesController(
    //     // addBuildingUseCase: Get.find<AddBuildingUseCase>(),
    //     // getBuildingsUseCase: Get.find<GetBuildingsUseCase>(),
    //     // updateBuildingUseCase: Get.find<UpdateBuildingUseCase>(),
    //     deleteRoomsUseCase: Get.find<DeleteRoomsUseCase>(),
    //   ),
    // );
  }
}
