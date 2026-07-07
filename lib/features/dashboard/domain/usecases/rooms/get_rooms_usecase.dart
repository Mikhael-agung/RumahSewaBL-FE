import '../../entities/rooms.dart';
import '../../repositories/rooms_repository.dart';

class GetRoomsUseCase {
  final RoomsRepository repository;

  GetRoomsUseCase(this.repository);

  Future<List<Room>> execute() {
    return repository.getRooms();
  }
}
