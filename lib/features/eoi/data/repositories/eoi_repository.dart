import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class EoiRepository {
  final Dio _dio;

  EoiRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.apiUrl,
          headers: {'Accept': 'application/json'},
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          validateStatus: (status) => status != null && status < 500,
        ));

  /// Submit an Expression of Interest for a summit
  Future<void> submitEoi(int summitId, Map<String, dynamic> data) async {
    try {
      final payload = {
        // Section A
        'full_name': data['full_name'],
        'phone': data['phone'],
        'email': data['email'],
        'business_name': data['business_name'],
        'state': data['state'],
        'preferred_location': data['preferred_location'],
        'how_heard': data['how_heard'],
        // Section B
        'sector': data['sector'],
        'primary_products': data['primary_products'],
        'cac_registration': data['cac_registration'],
        'nepc_registration': data['nepc_registration'],
        'export_status': data['export_status'],
        'recent_export_value': data['recent_export_value'],
        // Section C
        'commercial_scale': data['commercial_scale'] ? 1 : 0,
        'regulatory_registration': data['regulatory_registration'] ? 1 : 0,
        'regulatory_body': data['regulatory_body'],
        'certifications': data['certifications'],
        'seminar_goals': data['seminar_goals'],
      };

      final response = await _dio.post(
        '/summits/$summitId/eoi',
        data: payload,
      );

      if (response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Submission failed');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception(e.response?.data['message'] ??
          'Submission failed. Please try again.');
    } catch (e) {
      throw Exception('Submission failed: $e');
    }
  }

  /// Check EOI status by email and summit ID
  Future<Map<String, dynamic>> checkStatus(String email, int summitId) async {
    try {
      final response = await _dio.post('/summits/eoi/check-status', data: {
        'email': email,
        'summit_id': summitId,
      });

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else if (response.statusCode == 404) {
        throw Exception('No application found for this email and summit.');
      } else {
        throw Exception(response.data['message'] ?? 'Could not check status.');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception(e.response?.data['message'] ?? 'Could not check status.');
    }
  }

  /// Complete registration using selection token
  Future<void> completeRegistration({
    required String token,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/register/from-eoi', data: {
        'registration_token': token,
        'password': password,
        'password_confirmation': password,
        if (phone != null) 'phone': phone,
      });

      if (response.statusCode == 201) {
        return;
      } else if (response.statusCode == 403) {
        throw Exception(
            'Invalid or expired registration token. Please check your status again.');
      } else if (response.statusCode == 409) {
        throw Exception(response.data['message'] ?? 'Conflict error.');
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed.');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception(e.response?.data['message'] ??
          'Registration failed. Please try again.');
    }
  }
}
