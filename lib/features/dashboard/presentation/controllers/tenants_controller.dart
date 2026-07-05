import 'dart:developer';
import 'package:get/get.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/usecases/tenants/get_tenants_usecase.dart';
import '../../domain/usecases/tenants/get_tenant_detail_usecase.dart';
import '../../domain/usecases/tenants/add_tenant_usecase.dart';
import '../../domain/usecases/tenants/update_tenant_usecase.dart';
import '../../domain/usecases/tenants/delete_tenant_usecase.dart';

class TenantsController extends GetxController {
  final GetTenantsUseCase? getTenantsUseCase;
  final GetTenantDetailUseCase? getTenantDetailUseCase;
  final AddTenantUseCase? addTenantUseCase;
  final UpdateTenantUseCase? updateTenantUseCase;
  final DeleteTenantUseCase? deleteTenantUseCase;

  TenantsController({
    this.getTenantsUseCase,
    this.getTenantDetailUseCase,
    this.addTenantUseCase,
    this.updateTenantUseCase,
    this.deleteTenantUseCase,
  });

  var isLoading = true.obs;
  var tenants = <Tenant>[].obs;
  var accounts = <Account>[].obs;
  var filteredTenants = <Tenant>[].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTenants();
  }

  Future<void> fetchTenants() async {
    try {
      isLoading.value = true;
      // Add artificial delay for aesthetic premium experience matching properties view
      await Future.delayed(const Duration(milliseconds: 1500));
      if (getTenantsUseCase != null) {
        final result = await getTenantsUseCase!.execute();
        tenants.assignAll(result);
      }
      filterTenants(searchQuery.value);
    } catch (e) {
      log("Error fetching tenants: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void filterTenants(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredTenants.assignAll(tenants);
    } else {
      filteredTenants.assignAll(
        tenants.where(
          (t) =>
              t.fullName.toLowerCase().contains(query.toLowerCase()) ||
              t.tenantCode.toLowerCase().contains(query.toLowerCase()) ||
              t.email.toLowerCase().contains(query.toLowerCase()) ||
              t.phoneNumber.contains(query),
        ),
      );
    }
  }

  Future<Tenant> getTenantDetail(int id) async {
    try {
      if (getTenantDetailUseCase != null) {
        return await getTenantDetailUseCase!.execute(id);
      }
    } catch (e) {
      log("Error fetching tenant detail: $e");
    }

    final localTenant = tenants.firstWhereOrNull((t) => t.id == id);
    if (localTenant != null) {
      return localTenant;
    }

    throw Exception("Tenant dengan id $id tidak ditemukan");
  }

  Future<AddTenantResult> addTenant({
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      if (addTenantUseCase != null) {
        final result = await addTenantUseCase!.execute(
          tenantCode: tenantCode,
          fullName: fullName,
          phoneNumber: phoneNumber,
          email: email,
        );
        tenants.add(result.tenant);
        if (result.account != null) {
          accounts.add(result.account!);
        }
        filterTenants(searchQuery.value);
        return result;
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        final newTenant = Tenant(
          id: tenants.isEmpty
              ? 1
              : (tenants.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1),
          tenantCode: tenantCode,
          fullName: fullName,
          phoneNumber: phoneNumber,
          email: email,
        );
        tenants.add(newTenant);
        filterTenants(searchQuery.value);
        return AddTenantResult(tenant: newTenant);
      }
    } catch (e) {
      log("Error adding tenant: $e");
      // Fallback
      final newTenant = Tenant(
        id: tenants.isEmpty
            ? 1
            : (tenants.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1),
        tenantCode: tenantCode,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
      );
      tenants.add(newTenant);
      filterTenants(searchQuery.value);
      return AddTenantResult(tenant: newTenant);
    }
  }

  Future<bool> updateTenant({
    required int id,
    required String tenantCode,
    required String fullName,
    required String phoneNumber,
    required String email,
  }) async {
    try {
      Tenant updated;
      if (updateTenantUseCase != null) {
        updated = await updateTenantUseCase!.execute(
          id: id,
          tenantCode: tenantCode,
          fullName: fullName,
          phoneNumber: phoneNumber,
          email: email,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        updated = Tenant(
          id: id,
          tenantCode: tenantCode,
          fullName: fullName,
          phoneNumber: phoneNumber,
          email: email,
        );
      }
      final index = tenants.indexWhere((t) => t.id == id);
      if (index != -1) {
        tenants[index] = updated;
      }
      filterTenants(searchQuery.value);
      return true;
    } catch (e) {
      log("Error updating tenant: $e");
      // Fallback
      final updated = Tenant(
        id: id,
        tenantCode: tenantCode,
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
      );
      final index = tenants.indexWhere((t) => t.id == id);
      if (index != -1) {
        tenants[index] = updated;
      }
      filterTenants(searchQuery.value);
      return true;
    }
  }

  Future<bool> deleteTenant(int id) async {
    try {
      if (deleteTenantUseCase != null) {
        await deleteTenantUseCase!.execute(id);
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      tenants.removeWhere((t) => t.id == id);
      filterTenants(searchQuery.value);
      return true;
    } catch (e) {
      print("Error deleting tenant: $e");
      tenants.removeWhere((t) => t.id == id);
      filterTenants(searchQuery.value);
      return true;
    }
  }
}
