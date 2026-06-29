import '../../domain/entities/tenant.dart';
import '../../domain/repositories/tenants_repository.dart';
import '../datasources/tenants_remote_data_source.dart';

class TenantsRepositoryImpl implements TenantsRepository {
  final TenantsRemoteDataSource remoteDataSource;

  TenantsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Tenant>> getTenants() async {
    return await remoteDataSource.getTenants();
  }

  @override
  Future<AddTenantResult> addTenant({
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  }) async {
    return await remoteDataSource.addTenant(
      tenantCode: tenantCode,
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
    );
  }

  @override
  Future<Tenant> updateTenant({
    required int id,
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  }) async {
    return await remoteDataSource.updateTenant(
      id: id,
      tenantCode: tenantCode,
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
    );
  }

  @override
  Future<void> deleteTenant(int id) async {
    await remoteDataSource.deleteTenant(id);
  }
}
