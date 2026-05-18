import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login(String username, String password) async {
    return await remoteDataSource.login(username, password);
  }

  @override
  Future<void> logout(String jwtToken) async {
    return await remoteDataSource.logout(jwtToken);
  }
}
