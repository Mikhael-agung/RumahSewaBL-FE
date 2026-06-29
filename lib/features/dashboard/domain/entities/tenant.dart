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

class Account {
  final String username;
  final String password;
  final String note;

  const Account({
    required this.username,
    required this.password,
    required this.note,
  });

  Account copyWith({String? username, String? password, String? note}) {
    return Account(
      username: username ?? this.username,
      password: password ?? this.password,
      note: note ?? this.note,
    );
  }
}

class AddTenantResult {
  final Tenant tenant;
  final Account? account;

  const AddTenantResult({required this.tenant, this.account});
}
