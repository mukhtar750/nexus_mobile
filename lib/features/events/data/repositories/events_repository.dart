import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/event.dart';
import '../../../../core/constants/api_constants.dart';

class EventsRepository {
  final Dio _dio;

  EventsRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.apiUrl,
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ));

  Future<void> saveMyEvents(List<Event> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(
        events.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('my_events_cache', encodedData);
    } catch (e) {
      // Silently fail for cache errors
      print('Error caching my events: $e');
    }
  }

  Future<List<Event>> getEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _dio.get(
        '/events',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Event.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await prefs.remove('auth_token');
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Unable to load events. Please try again.');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception('Unexpected error occurred while loading events.');
    } catch (_) {
      throw Exception('Unexpected error occurred while loading events.');
    }
  }

  Future<List<Event>> getMyEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Please log in to view your tickets.');
      }

      final response = await _dio.get(
        '/user/events',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Event.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await prefs.remove('auth_token');
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Unable to load your tickets. Please try again.');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception('Unexpected error occurred while loading your tickets.');
    } catch (_) {
      throw Exception('Unexpected error occurred while loading your tickets.');
    }
  }

  Future<Event> getEvent(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _dio.get(
        '/events/$id',
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );
      if (response.statusCode == 200) {
        return Event.fromJson(response.data['data']);
      } else if (response.statusCode == 401) {
        await prefs.remove('auth_token');
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception('Unable to load event details. Please try again.');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception('Unexpected error occurred while loading event details.');
    } catch (_) {
      throw Exception('Unexpected error occurred while loading event details.');
    }
  }

  Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Please log in to register for this event.');
      }

      final response = await _dio.post(
        '/events/$eventId/register',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 401) {
        await prefs.remove('auth_token');
        throw Exception('Session expired. Please log in again.');
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw Exception(
            'Unable to connect. Please check your internet connection.');
      }
      throw Exception(e.response?.data['message'] ??
          'Registration failed. Please try again.');
    } catch (_) {
      throw Exception('Registration failed. Please try again.');
    }
  }
}
