import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/pending_approval_screen.dart';
import '../../features/auth/presentation/screens/user_type_selection_screen.dart';
import '../../features/auth/presentation/screens/register_guest_screen.dart';
import '../../features/auth/presentation/screens/guest_welcome_screen.dart';
import '../../features/events/presentation/screens/events_list_screen.dart';
import '../../features/ticket/presentation/screens/ticket_screen.dart';
import '../../features/ticket/presentation/screens/ticket_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../features/capacity_building/presentation/screens/capacity_building_screen.dart';
import '../features/capacity_building/presentation/screens/module_detail_screen.dart';
import '../features/capacity_building/presentation/screens/certificate_screen.dart';
import '../../features/staff/presentation/screens/qr_scanner_screen.dart';
import '../../features/staff/presentation/screens/scan_result_screen.dart';
import '../../features/events/domain/models/event.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/assessment/presentation/screens/assessment_intro_screen.dart';
import '../../features/assessment/presentation/screens/assessment_quiz_screen.dart';
import '../../features/assessment/presentation/screens/assessment_result_screen.dart';
import '../../features/resources/presentation/screens/resources_screen.dart';
import '../../features/resources/presentation/screens/markdown_resource_screen.dart';
import '../../features/resources/domain/models/resource.dart';
import '../../features/events/presentation/screens/invitations_screen.dart';
import 'widgets/main_wrapper.dart';

// Named routes map for Navigator.pushNamed
final Map<String, WidgetBuilder> routes = {
  // Keeping this for legacy support if needed, but prefer GoRouter
};

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorTicketKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellTicket');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      redirect: (context, state) => '/',
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const UserTypeSelectionScreen(),
    ),
    GoRoute(
      path: '/register/guest',
      builder: (context, state) => const RegisterGuestScreen(),
    ),
    GoRoute(
      path: '/register/exporter',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/pending-approval',
      builder: (context, state) => const PendingApprovalScreen(),
    ),
    GoRoute(
      path: '/guest-welcome',
      builder: (context, state) => const GuestWelcomeScreen(),
    ),
    GoRoute(
      path: '/capacity-building/:moduleId',
      builder: (context, state) {
        final moduleId = state.pathParameters['moduleId']!;
        return ModuleDetailScreen(moduleId: moduleId);
      },
    ),
    GoRoute(
      path: '/assessment',
      builder: (context, state) => const AssessmentIntroScreen(),
      routes: [
        GoRoute(
          path: 'quiz',
          builder: (context, state) => const AssessmentQuizScreen(),
        ),
        GoRoute(
          path: 'result',
          builder: (context, state) {
            final score = state.extra as int? ?? 0;
            return AssessmentResultScreen(score: score);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/staff/scan',
      builder: (context, state) => const QRScannerScreen(),
      routes: [
        GoRoute(
          path: 'result',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>?;
            return ScanResultScreen(
              success: extras?['success'] ?? false,
              message: extras?['message'] ?? 'Unknown result',
              data: extras?['data'],
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/resources',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EnhancedResourcesScreen(),
      routes: [
        GoRoute(
          path: 'view',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final resource = state.extra as Resource;
            return MarkdownResourceScreen(resource: resource);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/capacity-building',
      builder: (context, state) => const CapacityBuildingScreen(),
      routes: [
        GoRoute(
          path: 'certificate/:moduleId',
          builder: (context, state) {
            final moduleId = state.pathParameters['moduleId']!;
            final moduleTitle =
                state.uri.queryParameters['title'] ?? 'Module Completion';
            return CertificateScreen(
              moduleId: moduleId,
              moduleTitle: moduleTitle,
            );
          },
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapper(navigationShell: navigationShell);
      },
      branches: [
        // Home Branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'events',
                  builder: (context, state) => const EventsListScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      builder: (context, state) {
                        final event = state.extra as Event;
                        return EventDetailScreen(event: event);
                      },
                    ),
                    GoRoute(
                      path: 'ticket',
                      builder: (context, state) =>
                          const TicketScreen(fromRegistration: true),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Ticket Branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTicketKey,
          routes: [
            GoRoute(
              path: '/ticket',
              builder: (context, state) => TicketScreen(
                fromRegistration:
                    state.uri.queryParameters['fromRegistration'] == 'true',
              ),
              routes: [
                GoRoute(
                  path: 'detail',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final event = state.extra as Event;
                    return TicketDetailScreen(event: event);
                  },
                ),
              ],
            ),
          ],
        ),
        // Profile Branch
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'invitations',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const InvitationsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
