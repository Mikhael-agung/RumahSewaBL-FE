import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<void> logout(String jwtToken);
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
        final data = e.response?.data;
        if (data is Map) {
          message = data['message'] ?? message;
        } else if (data is String) {
          message = data;
        }
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        message = 'Koneksi terputus (Timeout)';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak terduga');
    }
  }

  @override
  Future<void> logout(String jwtToken) async {
    try {
      final response = await dio.post('/api/logout', options: Options(headers: {'Authorization': 'Bearer $jwtToken'}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to logout');
      }
    } on DioException catch (e) {
      String message = 'Terjadi kesalahan saat logout';
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          message = data['message'] ?? message;
        } else if (data is String) {
          message = data;
        }
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        message = 'Koneksi terputus (Timeout)';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak terduga');
    }
  }
}
