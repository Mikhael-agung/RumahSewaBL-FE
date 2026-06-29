import 'package:flutter/foundation.dart';
import 'package:rumah_sewa_biru_laut_fe/core/services/api_service.dart';
import '../models/tenant_model.dart';

abstract class TenantsRemoteDataSource {
  Future<List<TenantModel>> getTenants();
  Future<AddTenantResultModel> addTenant({
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  });
  Future<TenantModel> updateTenant({
    required int id,
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  });
  Future<void> deleteTenant(int id);
}

class TenantsRemoteDataSourceImpl implements TenantsRemoteDataSource {
  final ApiService apiService;

  TenantsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<TenantModel>> getTenants() async {
    try {
      final response = await apiService.get('/api/tenants');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final List<dynamic> dataList = (data is Map && data.containsKey('data'))
            ? data['data']
            : (data is List ? data : []);
        return dataList.map((json) => TenantModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get tenants');
      }
    } catch (e) {
      debugPrint(
        "API Error when fetching tenants: $e. Returning empty tenant list.",
      );
      return [];
    }
  }

  @override
  Future<AddTenantResultModel> addTenant({
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  }) async {
    final response = await apiService.post(
      '/api/tenants',
      data: {
        'tenant_code': tenantCode,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'email': email,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("response: ${response.data}");
      return AddTenantResultModel.fromJson(response.data);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to add tenant');
    }
  }

  @override
  Future<TenantModel> updateTenant({
    required int id,
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      final response = await apiService.put(
        '/api/tenants/$id',
        data: {
          'tenant_code': tenantCode,
          'full_name': fullName,
          'phone_number': phoneNumber,
          'email': email,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("response: ${response.data}");
        return TenantModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update tenant');
      }
    } catch (e) {
      debugPrint(
        "API Error when updating tenant: $e. Performing local simulation.",
      );
      return TenantModel(
        id: id,
        tenantCode: tenantCode,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
      );
    }
  }

  @override
  Future<void> deleteTenant(int id) async {
    try {
      final response = await apiService.delete('/api/tenants/$id');
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        debugPrint("Tenant deleted successfully");
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete tenant');
      }
    } catch (e) {
      debugPrint(
        "API Error when deleting tenant: $e. Performing local simulation.",
      );
    }
  }
}
