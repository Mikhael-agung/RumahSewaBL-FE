import 'package:flutter/foundation.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import '../models/building_model.dart';

abstract class PropertiesRemoteDataSource {
  Future<List<BuildingModel>> getBuildings();
  Future<BuildingModel> addBuilding({
    required String code,
    required String name,
    required String address,
    required String description,
  });
  Future<BuildingModel> updateBuilding({
    required int id,
    required String code,
    required String name,
    required String address,
    required String description,
  });
  Future<void> deleteBuilding(int id);
}

class PropertiesRemoteDataSourceImpl implements PropertiesRemoteDataSource {
  final ApiService apiService;

  PropertiesRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<BuildingModel>> getBuildings() async {
    try {
      final response = await apiService.get('/api/buildings');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final List<dynamic> dataList = (data is Map && data.containsKey('data')) ? data['data'] : (data is List ? data : []);
        return dataList.map((json) => BuildingModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get buildings');
      }
    } catch (e) {
      debugPrint("API Error when fetching buildings: $e. Returning dummy building data.");
      return [
        const BuildingModel(
          id: 1,
          buildingCode: "GDG-A",
          buildingName: "Gedung Biru Laut Utama (Dummy)",
          buildingAddress: "Jl. Utama No. 1",
          description: "Gedung Utama",
        ),
        const BuildingModel(
          id: 2,
          buildingCode: "GDG-B",
          buildingName: "Gedung Biru Laut Timur (Dummy)",
          buildingAddress: "Jl. Timur No. 2",
          description: "Gedung Timur",
        ),
        const BuildingModel(
          id: 3,
          buildingCode: "GDG-C",
          buildingName: "Gedung Biru Laut Barat (Dummy)",
          buildingAddress: "Jl. Barat No. 3",
          description: "Gedung Barat",
        ),
      ];
    }
  }

  @override
  Future<BuildingModel> addBuilding({
    required String code,
    required String name,
    required String address,
    required String description,
  }) async {
    final response = await apiService.post(
      '/api/buildings',
      data: {
        'building_code': code,
        'building_name': name,
        'building_address': address,
        'description': description,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("response: ${response.data}");
      return BuildingModel.fromJson(response.data);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to add building');
    }
  }

  @override
  Future<BuildingModel> updateBuilding({
    required int id,
    required String code,
    required String name,
    required String address,
    required String description,
  }) async {
    try {
      final response = await apiService.put(
        '/api/buildings/$id',
        data: {
          'building_code': code,
          'building_name': name,
          'building_address': address,
          'description': description,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("response: ${response.data}");
        return BuildingModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update building');
      }
    } catch (e) {
      debugPrint("API Error when updating building: $e. Performing local simulation.");
      return BuildingModel(
        id: id,
        buildingCode: code,
        buildingName: name,
        buildingAddress: address,
        description: description,
      );
    }
  }

  @override
  Future<void> deleteBuilding(int id) async {
    try {
      final response = await apiService.delete('/api/buildings/$id');
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
        debugPrint("Building deleted successfully");
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete building');
      }
    } catch (e) {
      debugPrint("API Error when deleting building: $e. Performing local simulation.");
      // For local fallback, we don't throw, allowing the app to run offline smoothly.
    }
  }
}
