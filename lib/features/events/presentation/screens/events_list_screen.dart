import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/events_provider.dart';
import '../widgets/event_skeleton.dart';
import '../widgets/event_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/event.dart';

class EventsListScreen extends ConsumerWidget {
  const EventsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(eventsProvider);
    final isSearching = eventsState.searchQuery.isNotEmpty;

    // Filter for upcoming events (only show if not searching)
    List<Event> upcomingEvents = [];
    if (!isSearching) {
      upcomingEvents = eventsState.events
          .where((e) => e.startTime.isAfter(DateTime.now()))
          .toList();
      upcomingEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    ref.listen(eventsProvider, (previous, next) {
      if (next.error != null && next.error!.contains("Session expired")) {
        context.go('/login');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Events"),
        backgroundColor: AppTheme.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) =>
                  ref.read(eventsProvider.notifier).setSearchQuery(value),
              decoration: InputDecoration(
                hintText: "Search events...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintStyle: const TextStyle(color: Colors.grey),
                fillColor: Colors.white.withOpacity(0.9),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: eventsState.isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => const EventSkeleton(),
            )
          : eventsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        eventsState.error!,
                        style: const TextStyle(color: AppTheme.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(eventsProvider.notifier).fetchEvents(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : eventsState.events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            isSearching
                                ? "No results for your search"
                                : "No events available",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (isSearching)
                            Text(
                              "Try a different keyword or clear search",
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(eventsProvider.notifier).fetchEvents();
                      },
                      child: CustomScrollView(
                        slivers: [
                          // Upcoming Events Section
                          if (upcomingEvents.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 24, 16, 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_fire_department,
                                        color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Upcoming Events",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 320,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: upcomingEvents.length,
                                  itemBuilder: (context, index) {
                                    final event = upcomingEvents[index];
                                    return Container(
                                      width: 280,
                                      margin: const EdgeInsets.only(right: 16),
                                      child: EventCard(
                                          event: event, isFeatured: true),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],

                          // All Events Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 24, 16, 16),
                              child: Text(
                                isSearching ? "Search Results" : "All Events",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),

                          // All Events List
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final event = eventsState.events[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: EventCard(event: event),
                                  );
                                },
                                childCount: eventsState.events.length,
                              ),
                            ),
                          ),

                          // Bottom padding
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 24),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
