class Poll {
  final int id;
  final int eventId;
  final String question;
  final bool isActive;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<PollOption> options;
  final int? userVotedOptionId;
  final int totalVotes;

  Poll({
    required this.id,
    required this.eventId,
    required this.question,
    required this.isActive,
    this.startTime,
    this.endTime,
    required this.options,
    this.userVotedOptionId,
    required this.totalVotes,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      eventId: json['event_id'],
      question: json['question'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => PollOption.fromJson(e))
              .toList() ??
          [],
      userVotedOptionId: json['user_voted_option_id'],
      totalVotes: json['total_votes'] ?? 0,
    );
  }
}

class PollOption {
  final int id;
  final int pollId;
  final String optionText;
  final int voteCount;
  final int percentage;

  PollOption({
    required this.id,
    required this.pollId,
    required this.optionText,
    required this.voteCount,
    required this.percentage,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'],
      pollId: json['poll_id'],
      optionText: json['option_text'],
      voteCount: json['vote_count'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}
