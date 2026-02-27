import '../../../../core/constants/api_constants.dart';

class Speaker {
  final int id;
  final String name;
  final String? title;
  final String? avatarUrl;
  final String? bio;
  final String? scheduleTime;

  Speaker({
    required this.id,
    required this.name,
    this.title,
    this.avatarUrl,
    this.bio,
    this.scheduleTime,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) {
    String? avatarUrl = json['avatar_url'] ?? json['photo_url'];
    // Use ApiConstants to normalize the URL (handle Android localhost)
    avatarUrl = ApiConstants.getValidUrl(avatarUrl);

    return Speaker(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      avatarUrl: avatarUrl,
      bio: json['bio'],
      scheduleTime: json['schedule_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'avatar_url': avatarUrl,
      'bio': bio,
      'schedule_time': scheduleTime,
    };
  }
}

class EventSession {
  final int id;
  final String title;
  final String speaker;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? userTypeRequired;

  EventSession({
    required this.id,
    required this.title,
    required this.speaker,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.userTypeRequired,
  });

  factory EventSession.fromJson(Map<String, dynamic> json) {
    return EventSession(
      id: json['id'],
      title: json['title'],
      speaker: json['speaker'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      location: json['location'],
      userTypeRequired: json['user_type_required'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'speaker': speaker,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'user_type_required': userTypeRequired,
    };
  }
}

class EventTicket {
  final int id;
  final int userId;
  final int eventId;
  final String qrCodeData;
  final String status;

  EventTicket({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.qrCodeData,
    required this.status,
  });

  factory EventTicket.fromJson(Map<String, dynamic> json) {
    return EventTicket(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      qrCodeData: json['qr_code_data'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'qr_code_data': qrCodeData,
      'status': status,
    };
  }
}

class Event {
  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? coverImageUrl;
  final List<Speaker> speakers;
  final List<EventSession> sessions;
  final bool isRegistered;
  final bool requiresInvitation;
  final EventTicket? ticket;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.coverImageUrl,
    this.speakers = const [],
    this.sessions = const [],
    this.isRegistered = false,
    this.requiresInvitation = false,
    this.ticket,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String? coverImageUrl = json['cover_image_url'];
    // Use ApiConstants to normalize the URL (handle Android localhost)
    coverImageUrl = ApiConstants.getValidUrl(coverImageUrl);

    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      location: json['location'],
      coverImageUrl: coverImageUrl,
      requiresInvitation: json['requires_invitation'] ?? false,
      isRegistered:
          (json['is_registered'] ?? false) || (json['ticket'] != null),
      ticket:
          json['ticket'] != null ? EventTicket.fromJson(json['ticket']) : null,
      speakers: json['speakers'] != null
          ? (json['speakers'] as List).map((i) => Speaker.fromJson(i)).toList()
          : [],
      sessions: json['sessions'] != null
          ? (json['sessions'] as List)
              .map((i) => EventSession.fromJson(i))
              .toList()
          : [],
    );
  }

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? coverImageUrl,
    List<Speaker>? speakers,
    List<EventSession>? sessions,
    bool? isRegistered,
    EventTicket? ticket,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      speakers: speakers ?? this.speakers,
      sessions: sessions ?? this.sessions,
      isRegistered: isRegistered ?? this.isRegistered,
      requiresInvitation: requiresInvitation ?? requiresInvitation,
      ticket: ticket ?? this.ticket,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'cover_image_url': coverImageUrl,
      'is_registered': isRegistered,
      'requires_invitation': requiresInvitation,
      'ticket': ticket?.toJson(),
      'speakers': speakers.map((e) => e.toJson()).toList(),
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }
}
