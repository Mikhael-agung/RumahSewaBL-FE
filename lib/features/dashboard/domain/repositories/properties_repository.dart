import '../entities/building.dart';

abstract class PropertiesRepository {
  Future<List<Building>> getBuildings();
  Future<Building> addBuilding({
    required String code,
    required String name,
    required String address,
    required String description,
  });
  Future<Building> updateBuilding({
    required int id,
    required String code,
    required String name,
    required String address,
    required String description,
  });
}
