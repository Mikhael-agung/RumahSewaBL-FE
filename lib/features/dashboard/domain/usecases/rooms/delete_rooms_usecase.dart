import 'package:rumah_sewa_biru_laut_fe/features/dashboard/domain/repositories/rooms_repository.dart';

class DeleteRoomsUseCase {
  final RoomsRepository repository;

  DeleteRoomsUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteRoom(id);
  }
}
