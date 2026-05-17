import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await dio.post('/api/login', data: {
        'username': username,
        'password': password,
      });

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to login');
      }
    } on DioException catch (e) {
      String message = 'Terjadi kesalahan saat login';
      if (e.response != null) {
        message = e.response?.data['message'] ?? message;
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        message = 'Koneksi terputus (Timeout)';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak terduga');
    }
  }
}
