class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final int totalPoints;
  final int rank;
  final int completedModules;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.totalPoints,
    required this.rank,
    required this.completedModules,
  });
}

class Leaderboard {
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUser;

  Leaderboard({
    required this.entries,
    this.currentUser,
  });

  int get totalUsers => entries.length;
}
