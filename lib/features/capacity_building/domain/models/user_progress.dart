import 'badge.dart';

class UserProgress {
  final int totalPoints;
  final int currentLevel;
  final int completedModules;
  final int completedLessons;
  final List<Badge> earnedBadges;
  final Map<String, int> modulePoints; // points per module
  final int currentLevelPoints;
  final int nextLevelPoints;
  final int streak; // Days of consecutive learning

  UserProgress({
    required this.totalPoints,
    required this.currentLevel,
    required this.completedModules,
    required this.completedLessons,
    required this.earnedBadges,
    required this.modulePoints,
    required this.currentLevelPoints,
    required this.nextLevelPoints,
    this.streak = 0,
  });

  // Level titles
  String get levelTitle {
    switch (currentLevel) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Learner';
      case 3:
        return 'Practitioner';
      case 4:
        return 'Expert';
      case 5:
        return 'Master Exporter';
      default:
        return 'Level $currentLevel';
    }
  }

  // Progress to next level (0.0 to 1.0)
  double get levelProgress {
    if (nextLevelPoints == 0) return 1.0;
    return currentLevelPoints / nextLevelPoints;
  }

  UserProgress copyWith({
    int? totalPoints,
    int? currentLevel,
    int? completedModules,
    int? completedLessons,
    List<Badge>? earnedBadges,
    Map<String, int>? modulePoints,
    int? currentLevelPoints,
    int? nextLevelPoints,
    int? streak,
  }) {
    return UserProgress(
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      completedModules: completedModules ?? this.completedModules,
      completedLessons: completedLessons ?? this.completedLessons,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      modulePoints: modulePoints ?? this.modulePoints,
      currentLevelPoints: currentLevelPoints ?? this.currentLevelPoints,
      nextLevelPoints: nextLevelPoints ?? this.nextLevelPoints,
      streak: streak ?? this.streak,
    );
  }

  // Calculate level from total points
  static int calculateLevel(int totalPoints) {
    if (totalPoints < 100) return 1;
    if (totalPoints < 300) return 2;
    if (totalPoints < 600) return 3;
    if (totalPoints < 1000) return 4;
    return 5;
  }

  // Calculate points needed for next level
  static int pointsForNextLevel(int currentLevel) {
    switch (currentLevel) {
      case 1:
        return 100;
      case 2:
        return 300;
      case 3:
        return 600;
      case 4:
        return 1000;
      default:
        return 0; // Max level reached
    }
  }

  // Points within current level
  static int pointsInCurrentLevel(int totalPoints, int level) {
    int previousLevelThreshold = 0;
    switch (level) {
      case 2:
        previousLevelThreshold = 100;
        break;
      case 3:
        previousLevelThreshold = 300;
        break;
      case 4:
        previousLevelThreshold = 600;
        break;
      case 5:
        previousLevelThreshold = 1000;
        break;
    }
    return totalPoints - previousLevelThreshold;
  }
}
