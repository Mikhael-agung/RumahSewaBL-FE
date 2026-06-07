import 'package:get/get.dart';
import '../../domain/entities/building.dart';
import '../../domain/usecases/add_building_usecase.dart';
import '../../domain/usecases/delete_building_usecase.dart';
import '../../domain/usecases/get_buildings_usecase.dart';
import '../../domain/usecases/update_building_usecase.dart';

class PropertiesController extends GetxController {
  final AddBuildingUseCase? addBuildingUseCase;
  final GetBuildingsUseCase? getBuildingsUseCase;
  final UpdateBuildingUseCase? updateBuildingUseCase;
  final DeleteBuildingUseCase? deleteBuildingUseCase;

  PropertiesController({
    this.addBuildingUseCase,
    this.getBuildingsUseCase,
    this.updateBuildingUseCase,
    this.deleteBuildingUseCase,
  });

  // Loading state
  var isLoading = true.obs;
  var isBuildingsLoading = true.obs;

  // Real entity list for Buildings
  var buildings = <Building>[].obs;

  // Mock data for Rooms
  var rooms = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPropertiesData();
  }

  Future<void> fetchPropertiesData() async {
    try {
      isLoading.value = true;
      isBuildingsLoading.value = true;

      await Future.wait([
        fetchBuildings(),
        fetchRooms(),
      ]);
    } catch (e) {
      // Handle error if any
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBuildings() async {
    try {
      isBuildingsLoading.value = true;
      // Add a small artificial delay of 1.5s to display the premium shimmer properly
      await Future.delayed(const Duration(milliseconds: 1500));
      if (getBuildingsUseCase != null) {
        final result = await getBuildingsUseCase!.execute();
        buildings.assignAll(result);
      }
    } catch (e) {
      // Fallback is handled inside the repository/datasource, but we catch here to be safe
    } finally {
      isBuildingsLoading.value = false;
    }
  }

  Future<void> fetchRooms() async {
    // Simulate network call loading delay (1.0 seconds)
    await Future.delayed(const Duration(milliseconds: 1000));
    rooms.value = [
      {"kode": "A-101", "gedung": "Utama", "harga": "Rp 2.500.000", "isTerisi": true},
      {"kode": "A-102", "gedung": "Utama", "harga": "Rp 2.000.000", "isTerisi": false},
      {"kode": "B-101", "gedung": "Timur", "harga": "Rp 2.500.000", "isTerisi": true},
      {"kode": "B-102", "gedung": "Timur", "harga": "Rp 2.000.000", "isTerisi": false},
      {"kode": "C-101", "gedung": "Barat", "harga": "Rp 2.500.000", "isTerisi": true},
    ];
  }

  void addRoom({required String kode, required String gedung, required String harga}) {
    rooms.add({
      "kode": kode,
      "gedung": gedung,
      "harga": harga,
      "isTerisi": false, // Default is false (Kosong)
    });
  }

  Future<bool> addBuilding({
    required String code,
    required String name,
    required String address,
    required String description,
  }) async {
    try {
      if (addBuildingUseCase != null) {
        final result = await addBuildingUseCase!.execute(
          code: code,
          name: name,
          address: address,
          description: description,
        );
        buildings.add(result);
      } else {
        // Fallback for direct testing
        await Future.delayed(const Duration(milliseconds: 500));
        final newBuilding = Building(
          id: buildings.isEmpty ? 1 : (buildings.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1),
          buildingCode: code,
          buildingName: name,
          buildingAddress: address,
          description: description,
        );
        buildings.add(newBuilding);
      }
      return true;
    } catch (e) {
      print("Error calling AddBuildingUseCase: $e");
      
      // Fallback/offline demo update
      final newBuilding = Building(
        id: buildings.isEmpty ? 1 : (buildings.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1),
        buildingCode: code,
        buildingName: name,
        buildingAddress: address,
        description: description,
      );
      buildings.add(newBuilding);
      return true;
    }
  }

  Future<bool> updateBuilding({
    required int id,
    required String code,
    required String name,
    required String address,
    required String description,
  }) async {
    try {
      Building updated;
      if (updateBuildingUseCase != null) {
        updated = await updateBuildingUseCase!.execute(
          id: id,
          code: code,
          name: name,
          address: address,
          description: description,
        );
      } else {
        // Fallback for direct testing
        await Future.delayed(const Duration(milliseconds: 500));
        updated = Building(
          id: id,
          buildingCode: code,
          buildingName: name,
          buildingAddress: address,
          description: description,
        );
      }

      final idx = buildings.indexWhere((b) => b.id == id);
      if (idx != -1) {
        buildings[idx] = updated;
      }
      return true;
    } catch (e) {
      print("Error calling UpdateBuildingUseCase: $e");
      
      // Fallback/offline demo update
      final updated = Building(
        id: id,
        buildingCode: code,
        buildingName: name,
        buildingAddress: address,
        description: description,
      );
      final idx = buildings.indexWhere((b) => b.id == id);
      if (idx != -1) {
        buildings[idx] = updated;
      }
      return true;
    }
  }

  Future<bool> deleteBuilding(int id) async {
    try {
      if (deleteBuildingUseCase != null) {
        await deleteBuildingUseCase!.execute(id);
      } else {
        // Fallback for direct testing
        await Future.delayed(const Duration(milliseconds: 500));
      }
      buildings.removeWhere((b) => b.id == id);

      // update buildings count lenghtnya
      print("Buildings count: ${buildings.length}");
      return true;
    } catch (e) {
      print("Error calling DeleteBuildingUseCase: $e");
      // Fallback/offline demo update
      buildings.removeWhere((b) => b.id == id);
      return true;
    }
  }
}
