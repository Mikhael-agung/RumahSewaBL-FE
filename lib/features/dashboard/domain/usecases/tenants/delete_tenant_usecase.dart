import '../../repositories/tenants_repository.dart';

class DeleteTenantUseCase {
  final TenantsRepository repository;

  DeleteTenantUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteTenant(id);
  }
}
