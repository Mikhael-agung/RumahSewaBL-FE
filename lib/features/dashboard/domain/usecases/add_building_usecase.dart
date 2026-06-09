import '../entities/building.dart';
import '../repositories/properties_repository.dart';

class AddBuildingUseCase {
  final PropertiesRepository repository;

  AddBuildingUseCase(this.repository);

  Future<Building> execute({
    required String code,
    required String name,
    required String address,
    required String description,
  }) {
    return repository.addBuilding(
      code: code,
      name: name,
      address: address,
      description: description,
    );
  }
}
