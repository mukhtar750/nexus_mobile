import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.apiUrl,
          headers: {'Accept': 'application/json'},
          connectTimeout: const Duration(seconds: 10), // Add timeout
          receiveTimeout: const Duration(seconds: 10), // Add timeout
          validateStatus: (status) => status != null && status < 500,
        ));

  Future<String?> login(String email, String password) async {
    print(
        'Attempting login to: ${ApiConstants.apiUrl}/auth/login'); // DEBUG LOG
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      print(
          'Login Response: ${response.statusCode} - ${response.data}'); // DEBUG LOG

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        return token;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      print('DioError: ${e.message} - ${e.response?.data}'); // DEBUG LOG
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Login failed: ${e.message}');
    } catch (e) {
      print('Unexpected Error: $e'); // DEBUG LOG
      throw Exception('Login failed: $e');
    }
  }

  Future<String?> register(Map<String, dynamic> data) async {
    try {
      final formDataMap = <String, dynamic>{
        'name': data['name'],
        'email': data['email'],
        'password': data['password'],
        'password_confirmation': data['password'],
        'phone': data['phone'],
        'business_name': data['business_name'],
        'business_address': data['business_address'],
        'year_established': data['year_established'],
        'business_structure': data['business_structure'],
        'cac_number': data['cac_number'],
        'product_category': data['product_category'],
        'registered_with_cac': data['registered_with_cac'] ? 1 : 0,
        'exported_before': data['exported_before'] ? 1 : 0,
        'registered_with_nepc': data['registered_with_nepc'] ? 1 : 0,
        'nepc_status': data['nepc_status'],
        'recent_export_activity': data['recent_export_activity'],
        'commercial_scale': data['commercial_scale'] ? 1 : 0,
        'packaged_for_retail': data['packaged_for_retail'] ? 1 : 0,
        'regulatory_registration': data['regulatory_registration'] ? 1 : 0,
        'engaged_logistics': data['engaged_logistics'] ? 1 : 0,
        'received_inquiries': data['received_inquiries'] ? 1 : 0,
        'production_location': data['production_location'],
        'production_compliant': data['production_compliant'] ? 1 : 0,
        'production_capacity': data['production_capacity'],
        'active_channels': data['active_channels'],
        'sales_model': data['sales_model'],
        'export_objective': data['export_objective'],
      };

      // Add Files if they exist
      if (data['profile_photo'] != null) {
        final file = data['profile_photo'] as File;
        formDataMap['profile_photo'] = await MultipartFile.fromFile(
          file.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Add Files if they exist
      if (data['cac_certificate'] != null) {
        final file = data['cac_certificate'] as File;
        formDataMap['cac_certificate'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      }

      if (data['nepc_certificate'] != null) {
        final file = data['nepc_certificate'] as File;
        formDataMap['nepc_certificate'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      }

      if (data['haccp_certificate'] != null) {
        final file = data['haccp_certificate'] as File;
        formDataMap['haccp_certificate'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      }

      if (data['fda_certificate'] != null) {
        final file = data['fda_certificate'] as File;
        formDataMap['fda_certificate'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      }

      if (data['halal_certificate'] != null) {
        final file = data['halal_certificate'] as File;
        formDataMap['halal_certificate'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      }

      if (data['son_certificate'] != null) {
        final file = data['son_certificate'] as File;
        formDataMap['son_certificate'] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.post('/auth/register', data: formData);

      if (response.statusCode == 201) {
        return 'pending';
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception(
        e.response?.data['message'] ?? 'Registration failed. Please try again.',
      );
    } catch (e) {
      print('Register Repository Error: $e');
      throw Exception('Registration failed. Please try again.');
    }
  }

  Future<String?> registerGuest({
    required String name,
    required String email,
    required String password,
    required String phone,
    File? profilePhoto,
  }) async {
    try {
      final formDataMap = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'phone': phone,
      };

      if (profilePhoto != null) {
        formDataMap['profile_photo'] = await MultipartFile.fromFile(
          profilePhoto.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await _dio.post('/auth/register/guest', data: formData);

      if (response.statusCode == 201 && response.data['token'] != null) {
        // Guest registration returns token immediately
        return response.data['token'];
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception(
        e.response?.data['message'] ?? 'Registration failed. Please try again.',
      );
    } catch (_) {
      throw Exception('Registration failed. Please try again.');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? company,
    String? bio,
    File? profilePhoto,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final formDataMap = <String, dynamic>{};
      if (name != null) formDataMap['name'] = name;
      if (phone != null) formDataMap['phone'] = phone;
      if (company != null) formDataMap['company'] = company;
      if (bio != null) formDataMap['bio'] = bio;

      if (profilePhoto != null) {
        formDataMap['profile_photo'] = await MultipartFile.fromFile(
          profilePhoto.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.post(
        '/user/profile',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Update failed');
      }
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Update failed: ${e.message}');
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }
}
