import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/models/summit.dart';

class SummitsRepository {
  final Dio _dio;

  SummitsRepository(this._dio);

  Future<List<Summit>> getActiveSummits() async {
    try {
      final response = await _dio.get('${ApiConstants.apiUrl}/summits');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Summit.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load summits');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No summits found
      }
      throw Exception('Unable to load summits: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error loading summits: $e');
    }
  }
}
