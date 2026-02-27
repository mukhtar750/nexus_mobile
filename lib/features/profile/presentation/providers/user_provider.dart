import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? company;
  final String? role;
  final String? userType;
  final String? bio;
  final String? avatarUrl;
  final bool hasCompletedAssessment;
  final bool exportedBefore;
  final String? readinessCategory;
  final String? analyticalSegment;
  final String? haccpCertificatePath;
  final String? fdaCertificatePath;
  final String? halalCertificatePath;
  final String? sonCertificatePath;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.company,
    this.role,
    this.userType,
    this.bio,
    this.avatarUrl,
    this.hasCompletedAssessment = false,
    this.exportedBefore = false,
    this.readinessCategory,
    this.analyticalSegment,
    this.haccpCertificatePath,
    this.fdaCertificatePath,
    this.halalCertificatePath,
    this.sonCertificatePath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle both direct role string (legacy) and roles array (new pivot table)
    String? role = json['role'];
    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      role = (json['roles'] as List)[0]['name']; // Primary role
    }

    String? avatarUrl = json['avatar_url'];
    if (avatarUrl != null && !avatarUrl.startsWith('http')) {
      avatarUrl =
          '${ApiConstants.baseUrl}${avatarUrl.startsWith('/') ? '' : '/'}$avatarUrl';
    }

    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      company: json['company'],
      role: role,
      userType: json['user_type'],
      bio: json['bio'],
      avatarUrl: avatarUrl,
      hasCompletedAssessment: json['has_completed_assessment'] ?? false,
      exportedBefore:
          json['exported_before'] == 1 || json['exported_before'] == true,
      readinessCategory: json['readiness_category'],
      analyticalSegment: json['analytical_segment'],
      haccpCertificatePath: json['haccp_certificate_path'],
      fdaCertificatePath: json['fda_certificate_path'],
      halalCertificatePath: json['halal_certificate_path'],
      sonCertificatePath: json['son_certificate_path'],
    );
  }

  // Helper to check for staff role
  bool get isStaff => role == 'staff' || role == 'admin';
  bool get isAdmin => role == 'admin';

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

class UserState {
  final bool isLoading;
  final User? user;
  final String? error;

  UserState({this.isLoading = false, this.user, this.error});
}

class UserNotifier extends StateNotifier<UserState> {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.apiUrl,
    headers: {'Accept': 'application/json'},
  ));

  UserNotifier() : super(UserState());

  Future<void> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      if (!mounted) return;
      state = UserState(error: 'Not authenticated');
      return;
    }

    if (!mounted) return;
    state = UserState(isLoading: true);
    try {
      final response = await _dio.get(
        '/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (!mounted) return;

      if (!mounted) return;
      if (response.statusCode == 200) {
        final userData = response.data;
        // Inject local assessment status if not yet in backend
        final localAssessmentStatus =
            prefs.getBool('assessment_completed_${userData['id']}') ?? false;
        final localReadinessCategory =
            prefs.getString('readiness_category_${userData['id']}');
        final localAnalyticalSegment =
            prefs.getString('analytical_segment_${userData['id']}');

        final user = User.fromJson({
          ...userData,
          'has_completed_assessment': localAssessmentStatus,
          'readiness_category': localReadinessCategory,
          'analytical_segment': localAnalyticalSegment,
        });
        if (!mounted) return;
        state = UserState(user: user);
      } else {
        if (response.statusCode == 401) {
          await prefs.remove('auth_token'); // Clear invalid token
          if (!mounted) return;
          state = UserState(error: 'Not authenticated');
        } else {
          if (!mounted) return;
          state = UserState(error: 'Failed to load user');
        }
      }
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && e.response?.statusCode == 401) {
        await prefs.remove('auth_token'); // Clear invalid token
        state = UserState(error: 'Not authenticated');
      } else {
        state = UserState(error: e.toString());
      }
    }
  }

  Future<void> setAssessmentCompleted({
    required String readinessCategory,
    required String analyticalSegment,
  }) async {
    if (state.user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('assessment_completed_${state.user!.id}', true);
    await prefs.setString(
        'readiness_category_${state.user!.id}', readinessCategory);
    await prefs.setString(
        'analytical_segment_${state.user!.id}', analyticalSegment);

    state = UserState(
      user: User(
        id: state.user!.id,
        name: state.user!.name,
        email: state.user!.email,
        phone: state.user!.phone,
        company: state.user!.company,
        role: state.user!.role,
        userType: state.user!.userType,
        bio: state.user!.bio,
        avatarUrl: state.user!.avatarUrl,
        hasCompletedAssessment: true,
        exportedBefore: state.user!.exportedBefore,
        readinessCategory: readinessCategory,
        analyticalSegment: analyticalSegment,
      ),
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final notifier = UserNotifier();
  notifier.fetchUser();
  return notifier;
});
