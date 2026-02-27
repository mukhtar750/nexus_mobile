import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/poll.dart';
import '../../domain/models/question.dart';
import '../../../../core/constants/api_constants.dart';

class EngagementRepository {
  final Dio _dio;

  EngagementRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.apiUrl,
          headers: {'Accept': 'application/json'},
        ));

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Poll>> getPolls(int eventId) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/events/$eventId/polls',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List).map((e) => Poll.fromJson(e)).toList();
  }

  Future<void> votePoll(int pollId, int optionId) async {
    final token = await _getToken();
    await _dio.post(
      '/polls/$pollId/vote',
      data: {'poll_option_id': optionId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<List<Question>> getQuestions(int eventId,
      {String sort = 'recent'}) async {
    final token = await _getToken();
    final response = await _dio.get(
      '/events/$eventId/questions',
      queryParameters: {'sort': sort},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List).map((e) => Question.fromJson(e)).toList();
  }

  Future<Question> postQuestion(int eventId, String content) async {
    final token = await _getToken();
    final response = await _dio.post(
      '/events/$eventId/questions',
      data: {'content': content},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Question.fromJson(response.data);
  }

  Future<void> upvoteQuestion(int questionId) async {
    final token = await _getToken();
    await _dio.post(
      '/questions/$questionId/upvote',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
