class Tenant {
  final int id;
  final String tenantCode;
  final String fullName;
  final String phoneNumber;
  final String email;

  const Tenant({
    required this.id,
    required this.tenantCode,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
  });

  Tenant copyWith({
    int? id,
    String? tenantCode,
    String? fullName,
    String? phoneNumber,
    String? email,
  }) {
    return Tenant(
      id: id ?? this.id,
      tenantCode: tenantCode ?? this.tenantCode,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}

