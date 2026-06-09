import '../../domain/entities/tenant.dart';

class TenantModel extends Tenant {
  const TenantModel({
    required super.id,
    required super.tenantCode,
    required super.fullName,
    required super.phoneNumber,
    required super.email,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return TenantModel(
      id: data['id'] ?? 0,
      tenantCode: data['tenant_code'] ?? '',
      fullName: data['full_name'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_code': tenantCode,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
    };
  }
}

