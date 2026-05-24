import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.role,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] ?? {};
    return UserModel(
      id: userObj['id'] ?? 0,
      username: userObj['username'] ?? '',
      role: userObj['role'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': {
        'id': id,
        'username': username,
        'role': role,
      }
    };
  }
}
