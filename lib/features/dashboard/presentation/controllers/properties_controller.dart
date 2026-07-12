import 'dart:developer';

import 'package:get/get.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/rooms.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/usecases/rooms/add_rooms_usecase.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/usecases/rooms/get_rooms_usecase.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/usecases/rooms/update_room_usecase.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/usecases/rooms/delete_rooms_usecase.dart';
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
  final AddRoomsUseCase? addRoomUseCase;
  final GetRoomsUseCase? getRoomsUseCase;
  final UpdateRoomUseCase? updateRoomUseCase;
  final DeleteRoomsUseCase? deleteRoomUseCase;

  PropertiesController({
    this.addBuildingUseCase,
    this.getBuildingsUseCase,
    this.updateBuildingUseCase,
    this.deleteBuildingUseCase,
    this.addRoomUseCase,
    this.getRoomsUseCase,
    this.updateRoomUseCase,
    this.deleteRoomUseCase,
  });

  // Loading state
  var isLoading = true.obs;
  var isBuildingsLoading = true.obs;
  var isRoomsLoading = true.obs;

  // Real entity list for Buildings
  var buildings = <Building>[].obs;

  // Real entity list for Rooms
  var rooms = <Room>[].obs;

  var selectedBuildingId = Rxn<int>();

  // Filtered rooms list
  List<Room> get filteredRooms => selectedBuildingId.value == null
      ? rooms
      : rooms.where((room) => room.buildingId == selectedBuildingId.value).toList();

  @override
  void onInit() {
    super.onInit();
    fetchPropertiesData();
  }

  Future<void> fetchPropertiesData() async {
    try {
      isLoading.value = true;
      isBuildingsLoading.value = true;
      isRoomsLoading.value = true;

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
      await Future.delayed(const Duration(milliseconds: 1500));
      if (getBuildingsUseCase != null) {
        final result = await getBuildingsUseCase!.execute();
        buildings.assignAll(result);
      }
    } finally {
      isBuildingsLoading.value = false;
    }
  }

  Future<void> fetchRooms() async {
    try {
      isRoomsLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 1000));
      if (getRoomsUseCase != null) {
        final result = await getRoomsUseCase!.execute();
        rooms.assignAll(result);
      }
    } catch (e) {
      log("Error fetching rooms: $e");
    } finally {
      isRoomsLoading.value = false;
    }
  }

  Future<bool> addRoom({
    required int buildingId,
    required String roomCode,
    required int monthlyPrice,
    required String roomStatus,
    required String notes,
  }) async {
    try {
      if (addRoomUseCase != null) {
        final result = await addRoomUseCase!.execute(
          id: buildingId, // maps to building_id
          code: roomCode,
          price: monthlyPrice,
          status: roomStatus,
          notes: notes,
        );
        rooms.insert(0, result);
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        final newRoom = Room(
          id: rooms.isEmpty ? 1 : (rooms.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1),
          buildingId: buildingId,
          roomCode: roomCode,
          monthlyPrice: monthlyPrice,
          roomStatus: roomStatus,
          notes: notes,
        );
        rooms.insert(0, newRoom);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateRoom({
    required int id,
    required int buildingId,
    required String roomCode,
    required int monthlyPrice,
    required String roomStatus,
    required String notes,
  }) async {
    try {
      Room updated;
      if (updateRoomUseCase != null) {
        updated = await updateRoomUseCase!.execute(
          id: id,
          buildingId: buildingId,
          roomCode: roomCode,
          monthlyPrice: monthlyPrice,
          roomStatus: roomStatus,
          notes: notes,
        );
      } else {
        // Fallback for direct testing
        await Future.delayed(const Duration(milliseconds: 500));
        updated = Room(
          id: id,
          buildingId: buildingId,
          roomCode: roomCode,
          monthlyPrice: monthlyPrice,
          roomStatus: roomStatus,
          notes: notes,
        );
      }

      final idx = rooms.indexWhere((r) => r.id == id);
      if (idx != -1) {
        rooms[idx] = updated;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRoom(int id) async {
    try {
      if (deleteRoomUseCase != null) {
        await deleteRoomUseCase!.execute(id);
      } else {
        // Fallback for direct testing
        await Future.delayed(const Duration(milliseconds: 500));
      }
      rooms.removeWhere((r) => r.id == id);
      return true;
    } catch (e) {
      return false;
    }
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
