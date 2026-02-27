import '../../domain/models/event.dart';

class Invitation {
  final int id;
  final String status;
  final Event? event;
  final int? invitedBy;
  final DateTime createdAt;

  Invitation({
    required this.id,
    required this.status,
    this.event,
    this.invitedBy,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isDeclined => status == 'declined';

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      status: json['status'],
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
      invitedBy: json['invited_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'event': event?.toJson(),
      'invited_by': invitedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Invitation copyWith({
    int? id,
    String? status,
    Event? event,
    int? invitedBy,
    DateTime? createdAt,
  }) {
    return Invitation(
      id: id ?? this.id,
      status: status ?? this.status,
      event: event ?? this.event,
      invitedBy: invitedBy ?? this.invitedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
