import '../repositories/properties_repository.dart';

class DeleteBuildingUseCase {
  final PropertiesRepository repository;

  DeleteBuildingUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteBuilding(id);
  }
}
