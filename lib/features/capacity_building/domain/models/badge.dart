class Badge {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int pointsRequired;
  final DateTime? earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.pointsRequired,
    this.earnedAt,
  });

  bool get isEarned => earnedAt != null;

  Badge copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    int? pointsRequired,
    DateTime? earnedAt,
  }) {
    return Badge(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }
}
