import '../entities/building.dart';
import '../repositories/properties_repository.dart';

class GetBuildingsUseCase {
  final PropertiesRepository repository;

  GetBuildingsUseCase(this.repository);

  Future<List<Building>> execute() {
    return repository.getBuildings();
  }
}
