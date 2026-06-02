import '../entities/building.dart';

abstract class PropertiesRepository {
  Future<Building> addBuilding({
    required String code,
    required String name,
    required String address,
    required String description,
  });
}
