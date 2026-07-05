import '../../domain/entities/building.dart';

class BuildingModel extends Building {
  const BuildingModel({
    required super.id,
    required super.buildingCode,
    required super.buildingName,
    required super.buildingAddress,
    required super.description,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    // If the backend returns wrapped or nested JSON, handle it appropriately
    final data = json['data'] ?? json;
    return BuildingModel(
      id: int.tryParse(data['id']?.toString() ?? '') ?? 0,
      buildingCode: data['building_code'] ?? '',
      buildingName: data['building_name'] ?? '',
      buildingAddress: data['building_address'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'building_code': buildingCode,
      'building_name': buildingName,
      'building_address': buildingAddress,
      'description': description,
    };
  }
}
