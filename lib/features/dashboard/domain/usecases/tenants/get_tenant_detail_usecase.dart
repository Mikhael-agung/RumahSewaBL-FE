import '../../entities/tenant.dart';
import '../../repositories/tenants_repository.dart';

class GetTenantDetailUseCase {
  final TenantsRepository repository;

  GetTenantDetailUseCase(this.repository);

  Future<Tenant> execute(int id) {
    return repository.getTenantDetail(id);
  }
}
