import 'package:flutter/foundation.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import '../models/building_model.dart';

abstract class PropertiesRemoteDataSource {
  Future<BuildingModel> addBuilding({
    required String code,
    required String name,
    required String address,
    required String description,
  });
}

class PropertiesRemoteDataSourceImpl implements PropertiesRemoteDataSource {
  final ApiService apiService;

  PropertiesRemoteDataSourceImpl({required this.apiService});

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
}
