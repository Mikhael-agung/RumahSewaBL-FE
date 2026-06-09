
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/rooms.dart';

abstract class RoomsRepository {
  Future<List<Room>> getRooms();
  Future<Room> addRoom({
    required int buildingId,
    required String roomCode,
    required int monthlyPrice,
    required String roomStatus,
    required String notes,
  });
  Future<Room> updateRoom({
    required int id,
    required int buildingId,
    required String roomCode,
    required int monthlyPrice,
    required String roomStatus,
    required String notes,
  });
  Future<void> deleteRoom(int id);
}
