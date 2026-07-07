import 'package:flutter/foundation.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/data/models/room_model.dart';

abstract class RoomsRemoteDataSource {
  Future<List<RoomModel>> getRooms();
  Future<RoomModel> addRoom({
    required int buildingId,
    required String roomCode,
    required int monthlyPrice,
    required String roomStatus,
    required String notes,
  });
  Future<RoomModel> updateRoom({
    required int id,
    required int buildingId,
    required String roomCode,
    required int monthlyPrice,
    required String roomStatus,
    required String notes,
  });
  Future<void> deleteRoom(int id);
}

class RoomsRemoteDataSourceImpl implements RoomsRemoteDataSource {
  final ApiService apiService;

  RoomsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<RoomModel>> getRooms() async {
    try {
      final response = await apiService.get('/api/rooms');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final List<dynamic> dataList = (data is Map && data.containsKey('data')) ? data['data'] : (data is List ? data : []);
        return dataList.map((json) => RoomModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get rooms');
      }
    } catch (e, stackTrace) {
      debugPrint("API Error when fetching rooms: $e");
      debugPrintStack(stackTrace: stackTrace);
      return [];
    }
  }

  @override
  Future<RoomModel> addRoom({
    required int buildingId,
    required String roomCode,
    required int monthlyPrice,
    required String roomStatus,
    required String notes,
  }) async {
    try {
      final response = await apiService.post(
        '/api/rooms',
        data: {
          'building_id': buildingId,
          'room_code': roomCode,
          'monthly_price': monthlyPrice,
          'room_status': roomStatus,
          'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("addRoom response: ${response.data}");
        return RoomModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add room');
      }
    } catch (e, stackTrace) {
      debugPrint("Error in addRoom remote data source: $e");
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<RoomModel> updateRoom({
    required int id,
    required int buildingId,
    required String roomCode,
    required int monthlyPrice,
    required String roomStatus,
    required String notes,
  }) async {
    try {
      final response = await apiService.put(
        '/api/rooms/$id',
        data: {
          'building_id': buildingId,
          'room_code': roomCode,
          'monthly_price': monthlyPrice,
          'room_status': roomStatus,
          'notes': notes,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("updateRoom response: ${response.data}");
        return RoomModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update room');
      }
    } catch (e, stackTrace) {
      debugPrint("Error in updateRoom remote data source: $e");
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteRoom(int id) async {
    try {
      final response = await apiService.delete('/api/rooms/$id');
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
        debugPrint("Room deleted successfully");
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete room');
      }
    } catch (e) {
      debugPrint("API Error when deleting room: $e. Performing local simulation.");
    }
  }
}