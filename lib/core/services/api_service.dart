import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumah_sewa_biru_laut_fe/core/constants/variables.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: ConstantVariable.baseUrl,
          connectTimeout: ConstantVariable.connectTimeout,
          receiveTimeout: ConstantVariable.receiveTimeout,
        )) {
    // Interceptor to automatically add jwt_token & common headers to every request!
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('jwt_token') ?? '';
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
    ));
  }

  // GET method
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      debugPrint("API GET Request to: ${ConstantVariable.baseUrl}$path");
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _handleDioError(e, "GET", path);
      rethrow;
    }
  }

  // POST method
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      debugPrint("API POST Request to: ${ConstantVariable.baseUrl}$path");
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      _handleDioError(e, "POST", path);
      rethrow;
    }
  }

  void _handleDioError(DioException e, String method, String path) {
    debugPrint("DioException occurred during $method to $path!");
    debugPrint("Status Code: ${e.response?.statusCode}");
    debugPrint("Error Message: ${e.message}");
    debugPrint("Response Data: ${e.response?.data}");
    
    String message = 'Terjadi kesalahan pada server';
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
  }
}
