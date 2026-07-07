import '../../entities/tenant.dart';
import '../../repositories/tenants_repository.dart';

class GetTenantsUseCase {
  final TenantsRepository repository;

  GetTenantsUseCase(this.repository);

  Future<List<Tenant>> execute() {
    return repository.getTenants();
  }
}
