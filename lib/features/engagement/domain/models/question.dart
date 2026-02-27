import '../../../profile/presentation/providers/user_provider.dart';

class Question {
  final int id;
  final int eventId;
  final int userId;
  final User? user;
  final String content;
  final DateTime createdAt;
  final int upvoteCount;
  final bool isUpvotedByMe;

  Question({
    required this.id,
    required this.eventId,
    required this.userId,
    this.user,
    required this.content,
    required this.createdAt,
    required this.upvoteCount,
    required this.isUpvotedByMe,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      upvoteCount: json['upvote_count'] ?? 0,
      isUpvotedByMe: json['is_upvoted_by_me'] ?? false,
    );
  }
}
