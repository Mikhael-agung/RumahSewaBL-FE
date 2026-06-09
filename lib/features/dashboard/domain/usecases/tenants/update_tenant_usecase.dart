import '../../entities/tenant.dart';
import '../../repositories/tenants_repository.dart';

class UpdateTenantUseCase {
  final TenantsRepository repository;

  UpdateTenantUseCase(this.repository);

  Future<Tenant> execute({
    required int id,
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  }) {
    return repository.updateTenant(
      id: id,
      tenantCode: tenantCode,
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
    );
  }
}

