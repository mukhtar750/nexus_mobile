import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';

class StaffRepository {
  final Dio _dio;

  StaffRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.apiUrl,
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ));

  Future<Map<String, dynamic>> verifyTicket(String ticketCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Please log in as staff to scan tickets.');
      }

      final response = await _dio.post(
        '/staff/verify-ticket',
        data: {'ticket_code': ticketCode},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401) {
        await prefs.remove('auth_token');
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('You are not authorized to scan tickets.');
      } else {
        throw Exception(
            response.data['message'] ?? 'Invalid or expired ticket.');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception(
        e.response?.data['message'] ??
            'Unable to verify ticket. Please try again.',
      );
    } catch (_) {
      throw Exception('Unable to verify ticket. Please try again.');
    }
  }
}
