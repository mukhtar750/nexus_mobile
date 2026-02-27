import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/event.dart';
import '../../data/repositories/events_repository.dart';

class EventsState {
  final bool isLoading;
  final List<Event> events;
  final List<Event> myEvents;
  final String? error;
  final bool isRegistering;
  final String? registrationError;
  final String? registrationSuccess;
  final Event? currentEvent;
  final String searchQuery;

  EventsState({
    this.isLoading = false,
    this.events = const [],
    this.myEvents = const [],
    this.error,
    this.isRegistering = false,
    this.registrationError,
    this.registrationSuccess,
    this.currentEvent,
    this.searchQuery = '',
  });

  EventsState copyWith({
    bool? isLoading,
    List<Event>? events,
    List<Event>? myEvents,
    String? error,
    bool? isRegistering,
    String? registrationError,
    String? registrationSuccess,
    Event? currentEvent,
    String? searchQuery,
  }) {
    return EventsState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      myEvents: myEvents ?? this.myEvents,
      error: error,
      isRegistering: isRegistering ?? this.isRegistering,
      registrationError: registrationError,
      registrationSuccess: registrationSuccess,
      currentEvent: currentEvent ?? this.currentEvent,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class EventsNotifier extends StateNotifier<EventsState> {
  final EventsRepository _repository;
  List<Event> _allEvents = [];

  EventsNotifier(this._repository) : super(EventsState()) {
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _repository.getEvents();
      if (!mounted) return;
      _allEvents = events;
      state = state.copyWith(isLoading: false, events: events);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: _friendlyError(
          e,
          fallback: 'Unable to load events. Please try again.',
        ),
      );
    }
  }

  Future<void> fetchEventDetails(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final event = await _repository.getEvent(id.toString());
      if (!mounted) return;
      state = state.copyWith(isLoading: false, currentEvent: event);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: _friendlyError(
          e,
          fallback: 'Unable to load event details. Please try again.',
        ),
      );
    }
  }

  void clearCurrentEvent() {
    state = state.copyWith(currentEvent: null);
  }

  void setSearchQuery(String query) {
    if (query.isEmpty) {
      state = state.copyWith(events: _allEvents, searchQuery: '');
      return;
    }

    final filtered = _allEvents.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase()) ||
          event.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    state = state.copyWith(events: filtered, searchQuery: query);
  }

  Future<void> fetchMyEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _repository.getMyEvents();
      if (!mounted) return;
      state = state.copyWith(isLoading: false, myEvents: events);
    } catch (e) {
      // Don't show error for my events as it might be empty or user not logged in
      // just clear loading
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
      print("Error fetching my events: $e");
    }
  }

  Future<void> registerForEvent(int eventId) async {
    state = state.copyWith(
        isRegistering: true,
        registrationError: null,
        registrationSuccess: null);
    try {
      final response = await _repository.registerForEvent(eventId.toString());

      if (!mounted) return;

      final ticketData = response['ticket'];
      final newTicket =
          ticketData != null ? EventTicket.fromJson(ticketData) : null;

      // Update local state to reflect registration
      final updatedEvent = state.currentEvent?.id == eventId
          ? state.currentEvent!.copyWith(isRegistered: true, ticket: newTicket)
          : null;

      // Also update the event in the main list
      final updatedEvents = state.events.map((e) {
        if (e.id == eventId) {
          return e.copyWith(isRegistered: true, ticket: newTicket);
        }
        return e;
      }).toList();

      // Update myEvents list
      List<Event> updatedMyEvents = [...state.myEvents];
      if (!updatedMyEvents.any((e) => e.id == eventId)) {
        // Find the event to add. Use updatedEvent or find in existing events.
        // If not found (rare), create a minimal one or fetch again.
        final eventToAdd = updatedEvent ??
            state.events
                .firstWhere((e) => e.id == eventId,
                    orElse: () => Event(
                        id: eventId,
                        title: 'Unknown Event',
                        description: '',
                        startTime: DateTime.now(),
                        endTime: DateTime.now(),
                        location:
                            '') // Fallback should ideally not happen if flow is correct
                    )
                .copyWith(isRegistered: true, ticket: newTicket);

        updatedMyEvents.add(eventToAdd);
      }

      state = state.copyWith(
        isRegistering: false,
        registrationSuccess: "Successfully registered!",
        currentEvent: updatedEvent ?? state.currentEvent,
        events: updatedEvents,
        myEvents: updatedMyEvents,
      );

      // Save updated myEvents to cache
      await _repository.saveMyEvents(updatedMyEvents);
      // Optionally refresh events to update UI if needed
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isRegistering: false,
        registrationError: _friendlyError(
          e,
          fallback: 'Unable to register for this event. Please try again.',
        ),
      );
    }
  }

  void clearRegistrationStatus() {
    state = state.copyWith(
      registrationError: null,
      registrationSuccess: null,
    );
  }
}

String _friendlyError(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  final message = error.toString();
  const prefix = 'Exception: ';
  if (message.startsWith(prefix)) {
    final stripped = message.substring(prefix.length);
    if (stripped.isNotEmpty) return stripped;
  }
  return message.isEmpty ? fallback : message;
}

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository();
});

final eventsProvider =
    StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  return EventsNotifier(repository);
});
