import '../../entities/rooms.dart';
import '../../repositories/rooms_repository.dart';

class UpdateRoomUseCase {
  final RoomsRepository repository;

  UpdateRoomUseCase(this.repository);

  Future<Room> execute({
    required int id,
    required int buildingId,
    required String roomCode,
    required int monthlyPrice,
    required String roomStatus,
    required String notes,
  }) {
    return repository.updateRoom(
      id: id,
      buildingId: buildingId,
      roomCode: roomCode,
      monthlyPrice: monthlyPrice,
      roomStatus: roomStatus,
      notes: notes,
    );
  }
}
