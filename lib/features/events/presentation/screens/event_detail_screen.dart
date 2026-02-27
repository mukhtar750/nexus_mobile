import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/event.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/api_constants.dart';
import '../providers/favorites_provider.dart';
import '../providers/events_provider.dart';
import 'invitations_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../engagement/presentation/widgets/polls_tab.dart';
import '../../../engagement/presentation/widgets/questions_tab.dart';
import '../widgets/enhanced_schedule_view.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Fetch full event details (speakers, schedule)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventsProvider.notifier).fetchEventDetails(widget.event.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);
    // Use the fetched full event if available and matches the ID, otherwise use the initial event
    final fullEvent = eventsState.currentEvent?.id == widget.event.id
        ? eventsState.currentEvent
        : null;
    final displayEvent = fullEvent ?? widget.event;

    // Listen for registration success/error
    ref.listen(eventsProvider, (previous, next) {
      if (next.registrationSuccess != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.registrationSuccess!),
            backgroundColor: AppTheme.success,
          ),
        );
        ref.read(eventsProvider.notifier).clearRegistrationStatus();
        context.push('/events/ticket', extra: {'fromRegistration': true});
      } else if (next.registrationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.registrationError!),
            backgroundColor: AppTheme.error,
          ),
        );
        ref.read(eventsProvider.notifier).clearRegistrationStatus();
      }
    });

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    final isFav =
                        ref.watch(favoritesProvider).contains(displayEvent.id);
                    return IconButton(
                      onPressed: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(displayEvent.id);
                      },
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : Colors.white,
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'event_image_${displayEvent.id}',
                  child: ApiConstants.getValidUrl(displayEvent.coverImageUrl) !=
                          null
                      ? CachedNetworkImage(
                          imageUrl: ApiConstants.getValidUrl(
                              displayEvent.coverImageUrl)!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppTheme.primary.withOpacity(0.2),
                            child: const Icon(
                              Icons.event,
                              size: 80,
                              color: AppTheme.primary,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary,
                                AppTheme.primary.withOpacity(0.7)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.event,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Speakers'),
                  Tab(text: 'Schedule'),
                  Tab(text: 'Engagement'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(displayEvent),
            _buildSpeakersTab(displayEvent, eventsState.isLoading),
            _buildScheduleTab(displayEvent, eventsState.isLoading),
            _buildEngagementTab(displayEvent),
          ],
        ),
      ),
      bottomNavigationBar: _buildRegisterButton(eventsState, displayEvent),
    );
  }

  Widget _buildEngagementTab(Event event) {
    if (!event.isRegistered) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                "Register for this event to participate in polls & Q&A",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: 'Live Polls'),
                Tab(text: 'Q&A'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                PollsTab(eventId: event.id),
                QuestionsTab(eventId: event.id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Event event) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.calendar_today,
            "${DateFormat('MMMM d, y').format(event.startTime)} - ${DateFormat('MMMM d, y').format(event.endTime)}",
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            "${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}",
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, event.location),
          const SizedBox(height: 24),
          const Text(
            "About Event",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 80), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildSpeakersTab(Event event, bool isLoading) {
    if (isLoading && event.speakers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(eventsProvider.notifier).fetchEventDetails(event.id);
      },
      child: event.speakers.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(child: Text("Speakers will be announced soon")),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: event.speakers.length,
              itemBuilder: (context, index) {
                final speaker = event.speakers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: speaker.avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: speaker.avatarUrl!,
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              radius: 30,
                              backgroundImage: imageProvider,
                            ),
                            placeholder: (context, url) => const CircleAvatar(
                              radius: 30,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => CircleAvatar(
                              radius: 30,
                              child: Text(
                                speaker.name.isNotEmpty ? speaker.name[0] : '?',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 30,
                            child: Text(
                              speaker.name.isNotEmpty ? speaker.name[0] : '?',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                    title: Text(
                      speaker.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (speaker.title != null)
                          Text(speaker.title!,
                              style: const TextStyle(color: AppTheme.primary)),
                        if (speaker.scheduleTime != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  speaker.scheduleTime!,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        if (speaker.bio != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              speaker.bio!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
              },
            ),
    );
  }

  Widget _buildScheduleTab(Event event, bool isLoading) {
    if (isLoading && event.sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(eventsProvider.notifier).fetchEventDetails(event.id);
      },
      child: event.sessions.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(child: Text("Schedule not available yet.")),
              ],
            )
          : EnhancedScheduleView(event: event),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(EventsState state, Event event) {
    // Check if registered in the event object OR in the myEvents list
    final isRegistered =
        event.isRegistered || state.myEvents.any((e) => e.id == event.id);

    if (isRegistered) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.push('/events/ticket', extra: {'fromRegistration': true});
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_number, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "View Ticket",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (state.isRegistering || event.requiresInvitation)
              ? (event.requiresInvitation
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InvitationsScreen(),
                        ),
                      )
                  : null)
              : () async {
                  await HapticFeedback.mediumImpact();
                  ref.read(eventsProvider.notifier).registerForEvent(event.id);
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor:
                event.requiresInvitation ? Colors.amber[800] : AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: state.isRegistering
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  event.requiresInvitation
                      ? "Check Invitations"
                      : "Register for Event",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
