import '../../entities/tenant.dart';
import '../../repositories/tenants_repository.dart';

class AddTenantUseCase {
  final TenantsRepository repository;

  AddTenantUseCase(this.repository);

  Future<Tenant> execute({
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  }) {
    return repository.addTenant(
      tenantCode: tenantCode,
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
    );
  }
}

