import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../events/presentation/providers/events_provider.dart';
import '../../../events/presentation/widgets/event_card.dart';
import '../../../events/domain/models/event.dart';
import '../providers/summits_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Timer will start when summits are loaded
  }

  void _startTimer(int summitCount) {
    if (summitCount == 0) return;
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < summitCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final eventsState = ref.watch(eventsProvider);
    final upcomingEvents = eventsState.events
        .where((e) => e.startTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(userState),
              const SizedBox(height: 24),
              _buildSummitSlider(),
              const SizedBox(height: 24),
              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context, userState),
              const SizedBox(height: 24),
              _buildActivitySummary(context, userState),
              const SizedBox(height: 24),
              _buildAssessmentBanner(context, userState),
              const SizedBox(height: 24),
              if (upcomingEvents.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Upcoming Events",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/events'),
                      child: const Text(
                        "View All",
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...upcomingEvents.take(3).map(
                      (event) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(event: event),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySummary(BuildContext context, UserState userState) {
    if (userState.user == null || userState.user?.userType == 'guest') {
      return const SizedBox.shrink();
    }

    final hasCompletedAssessment =
        userState.user?.hasCompletedAssessment ?? false;
    final readinessCategory = userState.user?.readinessCategory;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.dashboard_customize,
                  color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                "Export Journey Status",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasCompletedAssessment)
            _buildChecklistItem(
              "Complete Readiness Assessment",
              "Required to unlock capacity building",
              false,
              () => context.push('/assessment'),
            )
          else ...[
            _buildChecklistItem(
              "Export Readiness Assessment: ${readinessCategory ?? 'Completed'}",
              "Start Assessment",
              true,
              () => context.push(
                  '/assessment/result'), // Assuming this route exists or they find it via profile
            ),
            const SizedBox(height: 12),
            _buildChecklistItem(
              "Build Your Capacity",
              "Access Learning Modules",
              false, // Ideally tied to actual progress, but false prompts action
              () => context.push('/capacity-building'),
            ),
          ],
          const SizedBox(height: 12),
          _buildChecklistItem(
            "Upcoming Events",
            "View Events",
            false,
            () => context.push('/profile/invitations'),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
      String title, String subtitle, bool isCompleted, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.success.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle_outlined,
                size: 16,
                color: isCompleted ? AppTheme.success : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isCompleted ? AppTheme.text : AppTheme.textSecondary,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserState userState) {
    String displayName = "Exporter";
    if (userState.user != null) {
      displayName = userState.user!.name;
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primary,
          child: Text(
            displayName.substring(0, 2).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome back,",
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (userState.user?.userType == 'guest'
                              ? Colors.blue
                              : AppTheme.success)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userState.user?.userType == 'guest'
                          ? "Guest"
                          : "Verified",
                      style: TextStyle(
                        fontSize: 10,
                        color: userState.user?.userType == 'guest'
                            ? Colors.blue
                            : AppTheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Widget _buildSummitSlider() {
    final summitsState = ref.watch(summitsProvider);
    final summits = summitsState.summits;

    // Start timer when summits are loaded
    if (summits.isNotEmpty && !(_timer?.isActive ?? false)) {
      Future.microtask(() => _startTimer(summits.length));
    }

    // Show loading state
    if (summitsState.isLoading && summits.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Show empty state if no summits
    if (summits.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: summits.length,
        itemBuilder: (context, index) {
          final summit = summits[index];
          final eventsState = ref.watch(eventsProvider);

          return InkWell(
            onTap: () {
              if (summit.eventId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Event registration opening soon!"),
                    backgroundColor: AppTheme.primary,
                  ),
                );
                return;
              }

              // Find the event in the events list
              final event = eventsState.events.firstWhere(
                (e) => e.id == summit.eventId,
                orElse: () => Event(
                  id: summit.eventId!,
                  title: summit.title,
                  description: "Details coming soon...",
                  startTime: DateTime.now(),
                  endTime: DateTime.now(),
                  location: summit.venue,
                ),
              );

              context.push('/events/detail', extra: event);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder Pattern/Image
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        "assets/images/logo.png",
                        repeat: ImageRepeat.repeat,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                summit.zone,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            if (summit.eventId != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.how_to_reg,
                                        color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      "REGISTER",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          summit.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: AppTheme.accent, size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                summit.date,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                summit.venue,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Indicators
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Row(
                      children: List.generate(
                        summits.length,
                        (dotIndex) => Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == dotIndex
                                ? AppTheme.accent
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, UserState userState) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildActionCard(
          context,
          icon: Icons.school,
          title: "Capacity Building",
          color: AppTheme.success,
          locked: !(userState.user?.hasCompletedAssessment ?? false),
          onTap: () {
            if (userState.user?.hasCompletedAssessment ?? false) {
              context.push('/capacity-building');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      "Please complete the Export Readiness Assessment first."),
                  backgroundColor: AppTheme.primary,
                ),
              );
            }
          },
        ),
        _buildActionCard(
          context,
          icon: Icons.calendar_today,
          title: "Events",
          color: AppTheme.primary,
          onTap: () => context.push('/events'),
        ),
        _buildActionCard(
          context,
          icon: Icons.folder_open,
          title: "Resources",
          color: AppTheme.accent,
          onTap: () => context.push('/resources'),
        ),
        _buildActionCard(
          context,
          icon: Icons.confirmation_number,
          title: "View Ticket",
          color: AppTheme.warning,
          onTap: () {}, // QR ticket view
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool locked = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Stack(
          children: [
            Center(
              child: Opacity(
                opacity: locked ? 0.3 : 1.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (locked)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentBanner(BuildContext context, UserState userState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      userState.user?.hasCompletedAssessment ?? false
                          ? "Learning Journey"
                          : "Export Readiness",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  userState.user?.hasCompletedAssessment ?? false
                      ? "Keep building your capacity to master the international market."
                      : "Are you ready to go global? Take our self-assessment test",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (userState.user?.hasCompletedAssessment ?? false) {
                      context.push('/capacity-building');
                    } else {
                      context.push('/assessment');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    userState.user?.hasCompletedAssessment ?? false
                        ? "Resume Learning"
                        : "Start Assessment",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.assessment, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}
