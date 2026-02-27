import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/invitation.dart';

class InvitationsRepository {
  final Dio _dio;

  InvitationsRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.apiUrl,
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ));

  Future<List<Invitation>> getInvitations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _dio.get(
        '/invitations',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Invitation.fromJson(json)).toList();
      }
      throw Exception('Failed to load invitations');
    } catch (e) {
      rethrow;
    }
  }

  Future<Invitation> respondToInvitation(
      int invitationId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _dio.post(
        '/invitations/$invitationId/respond',
        data: {'status': status},
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      if (response.statusCode == 200) {
        return Invitation.fromJson(response.data['invitation']);
      }
      throw Exception(
          response.data['message'] ?? 'Failed to respond to invitation');
    } catch (e) {
      rethrow;
    }
  }
}
