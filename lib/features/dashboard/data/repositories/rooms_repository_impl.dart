import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/rooms.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/repositories/rooms_repository.dart';
import '../datasources/rooms_remote_data_source.dart';

class RoomsRepositoryImpl implements RoomsRepository {
  final RoomsRemoteDataSource remoteDataSource;

  RoomsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Room>> getRooms() async {
    return await remoteDataSource.getRooms();
  }

  @override
  Future<Room> addRoom({
    required int buildingId,
    required int monthlyPrice,
    required String notes,
    required String roomCode,
    required String roomStatus,
  }) async {
    return await remoteDataSource.addRoom(
      buildingId: buildingId,
      monthlyPrice: monthlyPrice,
      notes: notes,
      roomCode: roomCode,
      roomStatus: roomStatus,
    );
  }

  @override
  Future<Room> updateRoom({
    required int buildingId,
    required int id,
    required int monthlyPrice,
    required String notes,
    required String roomCode,
    required String roomStatus,
  }) async {
    return await remoteDataSource.updateRoom(
      id: id,
      buildingId: buildingId,
      roomCode: roomCode,
      monthlyPrice: monthlyPrice,
      roomStatus: roomStatus,
      notes: notes,
    );
  }

  @override
  Future<void> deleteRoom(int id) async {
    await remoteDataSource.deleteRoom(id);
  }
}
