import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exporthub_mobile/features/events/domain/models/event.dart';
import 'package:exporthub_mobile/features/events/presentation/screens/event_detail_screen.dart';
import 'package:exporthub_mobile/features/events/presentation/providers/events_provider.dart';
import 'package:exporthub_mobile/features/events/data/repositories/events_repository.dart';

// Fake repository for testing
class FakeEventsRepository implements EventsRepository {
  @override
  Future<List<Event>> getEvents() async => [];

  @override
  Future<Event> getEvent(String id) async {
    return Event(
      id: 1,
      title: 'Test Event Full',
      description: 'Description Full',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      location: 'Location',
      speakers: [Speaker(id: 1, name: 'Speaker 1', title: 'CEO')],
      sessions: [
        EventSession(
            id: 1,
            title: 'Session 1',
            speaker: 'Speaker 1',
            startTime: DateTime.now(),
            endTime: DateTime.now(),
            location: 'Room 1')
      ],
      isRegistered: false,
    );
  }

  @override
  Future<Map<String, dynamic>> registerForEvent(String id) async {
    return {'message': 'Success'};
  }

  @override
  Future<List<Event>> getMyEvents() async {
    return [];
  }

  @override
  Future<void> saveMyEvents(List<Event> events) async {}
}

void main() {
  testWidgets('EventDetailScreen loads and displays event details',
      (WidgetTester tester) async {
    final event = Event(
      id: 1,
      title: 'Test Event',
      description: 'Description',
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      location: 'Location',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventsRepositoryProvider.overrideWithValue(FakeEventsRepository()),
        ],
        child: MaterialApp(
          home: EventDetailScreen(event: event),
        ),
      ),
    );

    // Initial load check
    expect(find.text('Test Event'), findsOneWidget);

    // Wait for async fetch
    await tester.pumpAndSettle();

    // Check if tabs are present
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Speakers'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);

    // Check speakers tab
    await tester.tap(find.text('Speakers'));
    await tester.pumpAndSettle();
    expect(find.text('Speaker 1'), findsOneWidget);
    expect(find.text('CEO'), findsOneWidget);

    // Check schedule tab
    await tester.tap(find.text('Schedule'));
    await tester.pumpAndSettle();
    expect(find.text('Session 1'), findsOneWidget);
  });
}
