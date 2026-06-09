import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import '../data/datasources/properties_remote_data_source.dart';
import '../data/repositories/properties_repository_impl.dart';
import '../domain/repositories/properties_repository.dart';
import '../domain/usecases/add_building_usecase.dart';
import '../domain/usecases/delete_building_usecase.dart';
import '../domain/usecases/get_buildings_usecase.dart';
import '../domain/usecases/update_building_usecase.dart';
import '../presentation/controllers/properties_controller.dart';

// Rooms Clean Architecture dependencies
import '../data/datasources/rooms_remote_data_source.dart';
import '../data/repositories/rooms_repository_impl.dart';
import '../domain/repositories/rooms_repository.dart';
import '../domain/usecases/rooms/get_rooms_usecase.dart';
import '../domain/usecases/rooms/add_rooms_usecase.dart';
import '../domain/usecases/rooms/update_room_usecase.dart';
import '../domain/usecases/rooms/delete_rooms_usecase.dart';

class PropertiesBinding extends Bindings {
  @override
  void dependencies() {
    // If Dio is not already put globally, register a fallback
    if (!Get.isRegistered<Dio>()) {
      Get.lazyPut<Dio>(() => Dio());
    }

    Get.lazyPut<PropertiesRemoteDataSource>(
      () => PropertiesRemoteDataSourceImpl(apiService: Get.find<ApiService>()),
    );

    Get.lazyPut<PropertiesRepository>(
      () => PropertiesRepositoryImpl(remoteDataSource: Get.find()),
    );

    Get.lazyPut<AddBuildingUseCase>(
      () => AddBuildingUseCase(Get.find<PropertiesRepository>()),
    );

    Get.lazyPut<GetBuildingsUseCase>(
      () => GetBuildingsUseCase(Get.find<PropertiesRepository>()),
    );

    Get.lazyPut<UpdateBuildingUseCase>(
      () => UpdateBuildingUseCase(Get.find<PropertiesRepository>()),
    );

    Get.lazyPut<DeleteBuildingUseCase>(
      () => DeleteBuildingUseCase(Get.find<PropertiesRepository>()),
    );

    // Rooms bindings
    Get.lazyPut<RoomsRemoteDataSource>(
      () => RoomsRemoteDataSourceImpl(apiService: Get.find<ApiService>()),
    );

    Get.lazyPut<RoomsRepository>(
      () => RoomsRepositoryImpl(remoteDataSource: Get.find()),
    );

    Get.lazyPut<GetRoomsUseCase>(
      () => GetRoomsUseCase(Get.find<RoomsRepository>()),
    );

    Get.lazyPut<AddRoomsUseCase>(
      () => AddRoomsUseCase(Get.find<RoomsRepository>()),
    );

    Get.lazyPut<UpdateRoomUseCase>(
      () => UpdateRoomUseCase(Get.find<RoomsRepository>()),
    );

    Get.lazyPut<DeleteRoomsUseCase>(
      () => DeleteRoomsUseCase(Get.find<RoomsRepository>()),
    );

    Get.lazyPut<PropertiesController>(
      () => PropertiesController(
        addBuildingUseCase: Get.find<AddBuildingUseCase>(),
        getBuildingsUseCase: Get.find<GetBuildingsUseCase>(),
        updateBuildingUseCase: Get.find<UpdateBuildingUseCase>(),
        deleteBuildingUseCase: Get.find<DeleteBuildingUseCase>(),
        addRoomUseCase: Get.find<AddRoomsUseCase>(),
        getRoomsUseCase: Get.find<GetRoomsUseCase>(),
        updateRoomUseCase: Get.find<UpdateRoomUseCase>(),
        deleteRoomUseCase: Get.find<DeleteRoomsUseCase>(),
      ),
    );
  }
}
