import '../../domain/models/badge.dart';
import '../../domain/models/user_progress.dart';
import '../../domain/models/leaderboard.dart';

class GamificationRepository {
  // Available badges
  static final List<Badge> _allBadges = [
    Badge(
      id: 'first_steps',
      name: 'First Steps',
      description: 'Complete your first lesson',
      emoji: '🎯',
      pointsRequired: 0,
    ),
    Badge(
      id: 'knowledge_seeker',
      name: 'Knowledge Seeker',
      description: 'Complete 5 lessons',
      emoji: '📚',
      pointsRequired: 50,
    ),
    Badge(
      id: 'quiz_master',
      name: 'Quiz Master',
      description: 'Pass 3 quizzes with 90%+',
      emoji: '🏆',
      pointsRequired: 150,
    ),
    Badge(
      id: 'module_champion',
      name: 'Module Champion',
      description: 'Complete one full module',
      emoji: '⭐',
      pointsRequired: 200,
    ),
    Badge(
      id: 'export_expert',
      name: 'Export Expert',
      description: 'Complete all 5 modules',
      emoji: '🌟',
      pointsRequired: 1000,
    ),
    Badge(
      id: 'perfect_score',
      name: 'Perfect Score',
      description: 'Get 100% on any quiz',
      emoji: '🎓',
      pointsRequired: 100,
    ),
    Badge(
      id: 'streak_master',
      name: 'Streak Master',
      description: '7-day learning streak',
      emoji: '🔥',
      pointsRequired: 70,
    ),
  ];

  // Mock user progress (in real app, this would come from backend)
  static UserProgress _mockProgress = UserProgress(
    totalPoints: 0,
    currentLevel: 1,
    completedModules: 0,
    completedLessons: 0,
    earnedBadges: [],
    modulePoints: {
      'gmp': 0,
      'branding': 0,
      'export_process': 0,
      'regulations': 0,
      'business_dev': 0,
    },
    currentLevelPoints: 0,
    nextLevelPoints: 100,
    streak: 0,
  );

  Future<UserProgress> getUserProgress(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Calculate current level and progress
    final level = UserProgress.calculateLevel(_mockProgress.totalPoints);
    final nextLevelPoints = UserProgress.pointsForNextLevel(level);
    final currentLevelPoints = UserProgress.pointsInCurrentLevel(
      _mockProgress.totalPoints,
      level,
    );

    // Check earned badges
    final earnedBadges = _checkEarnedBadges();

    return _mockProgress.copyWith(
      currentLevel: level,
      currentLevelPoints: currentLevelPoints,
      nextLevelPoints: nextLevelPoints == 0
          ? 1
          : nextLevelPoints -
              (level == 1 ? 0 : UserProgress.pointsForNextLevel(level - 1)),
      earnedBadges: earnedBadges,
    );
  }

  Future<void> awardPoints(String userId, int points, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _mockProgress = _mockProgress.copyWith(
      totalPoints: _mockProgress.totalPoints + points,
    );
  }

  Future<List<Badge>> getAllBadges() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final earnedBadgeIds = _mockProgress.earnedBadges.map((b) => b.id).toSet();

    return _allBadges.map((badge) {
      if (earnedBadgeIds.contains(badge.id)) {
        final earnedBadge =
            _mockProgress.earnedBadges.firstWhere((b) => b.id == badge.id);
        return badge.copyWith(earnedAt: earnedBadge.earnedAt);
      }
      return badge;
    }).toList();
  }

  Future<Leaderboard> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock leaderboard data
    final entries = [
      LeaderboardEntry(
        userId: '1',
        userName: 'Amina Bello',
        totalPoints: 850,
        rank: 1,
        completedModules: 4,
      ),
      LeaderboardEntry(
        userId: '2',
        userName: 'Chidi Okafor',
        totalPoints: 720,
        rank: 2,
        completedModules: 3,
      ),
      LeaderboardEntry(
        userId: '3',
        userName: 'Fatima Yusuf',
        totalPoints: 650,
        rank: 3,
        completedModules: 3,
      ),
      LeaderboardEntry(
        userId: 'current',
        userName: 'You',
        totalPoints: _mockProgress.totalPoints,
        rank: 8,
        completedModules: _mockProgress.completedModules,
      ),
      LeaderboardEntry(
        userId: '4',
        userName: 'Emeka Nwankwo',
        totalPoints: 580,
        rank: 4,
        completedModules: 2,
      ),
      LeaderboardEntry(
        userId: '5',
        userName: 'Aisha Mohammed',
        totalPoints: 520,
        rank: 5,
        completedModules: 2,
      ),
    ];

    // Sort by points
    entries.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    final currentUser = entries.firstWhere((e) => e.userId == 'current');

    return Leaderboard(
      entries: entries,
      currentUser: currentUser,
    );
  }

  List<Badge> _checkEarnedBadges() {
    final earnedBadges = <Badge>[];
    final now = DateTime.now();

    // First Steps - complete first lesson
    if (_mockProgress.completedLessons >= 1) {
      earnedBadges.add(_allBadges[0]
          .copyWith(earnedAt: now.subtract(const Duration(days: 2))));
    }

    // Knowledge Seeker - 5 lessons
    if (_mockProgress.completedLessons >= 5) {
      earnedBadges.add(_allBadges[1]
          .copyWith(earnedAt: now.subtract(const Duration(days: 1))));
    }

    // Module Champion - 1 module
    if (_mockProgress.completedModules >= 1) {
      earnedBadges.add(_allBadges[3].copyWith(earnedAt: now));
    }

    return earnedBadges;
  }

  // Points calculation
  static const int pointsPerLesson = 10;
  static const int pointsPerQuiz70 = 20;
  static const int pointsPerQuiz80 = 30;
  static const int pointsPerQuiz90 = 50;
  static const int pointsPerModule = 100;

  int calculateQuizPoints(int percentage) {
    if (percentage >= 90) return pointsPerQuiz90;
    if (percentage >= 80) return pointsPerQuiz80;
    if (percentage >= 70) return pointsPerQuiz70;
    return 0;
  }
}
