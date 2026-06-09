
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/entities/rooms.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/repositories/rooms_repository.dart';

class AddRoomsUseCase {
  final RoomsRepository repository;

  AddRoomsUseCase(this.repository);

  Future<Room> execute({
    required int id,
    required String code,
    required int price,
    required String status,
    required String notes,
  }) {
    return repository.addRoom(
      buildingId: id,
      roomCode: code,
      monthlyPrice: price,
      roomStatus: status,
      notes: notes,
    );
  }
}
