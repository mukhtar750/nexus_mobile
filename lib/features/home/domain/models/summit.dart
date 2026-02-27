class Summit {
  final int id;
  final int? eventId;
  final String title;
  final String city;
  final String zone;
  final String date;
  final String venue;
  final bool isActive;

  Summit({
    required this.id,
    this.eventId,
    required this.title,
    required this.city,
    required this.zone,
    required this.date,
    required this.venue,
    required this.isActive,
  });

  factory Summit.fromJson(Map<String, dynamic> json) {
    return Summit(
      id: json['id'] as int,
      eventId: json['event_id'] as int?,
      title: json['title'] as String,
      city: json['city'] as String,
      zone: json['zone'] as String,
      date: json['date'] as String,
      venue: json['venue'] as String,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'title': title,
      'city': city,
      'zone': zone,
      'date': date,
      'venue': venue,
      'is_active': isActive,
    };
  }
}
