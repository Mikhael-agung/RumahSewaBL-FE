import '../entities/tenant.dart';

abstract class TenantsRepository {
  Future<List<Tenant>> getTenants();
  Future<Tenant> addTenant({
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  });
  Future<Tenant> updateTenant({
    required int id,
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  });
  Future<void> deleteTenant(int id);
}

