import '../entities/building.dart';
import '../repositories/properties_repository.dart';

class UpdateBuildingUseCase {
  final PropertiesRepository repository;

  UpdateBuildingUseCase(this.repository);

  Future<Building> execute({
    required int id,
    required String code,
    required String name,
    required String address,
    required String description,
  }) {
    return repository.updateBuilding(
      id: id,
      code: code,
      name: name,
      address: address,
      description: description,
    );
  }
}
