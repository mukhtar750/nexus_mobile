import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../domain/models/user_progress.dart';
import '../../domain/models/badge.dart';
import '../../domain/models/leaderboard.dart';

final gamificationRepositoryProvider =
    Provider((ref) => GamificationRepository());

final userProgressProvider = FutureProvider<UserProgress>((ref) async {
  final repository = ref.watch(gamificationRepositoryProvider);
  return repository.getUserProgress('current_user');
});

final allBadgesProvider = FutureProvider<List<Badge>>((ref) async {
  final repository = ref.watch(gamificationRepositoryProvider);
  return repository.getAllBadges();
});

final leaderboardProvider = FutureProvider<Leaderboard>((ref) async {
  final repository = ref.watch(gamificationRepositoryProvider);
  return repository.getLeaderboard();
});

// Action to award points
class GamificationNotifier extends StateNotifier<AsyncValue<UserProgress>> {
  final GamificationRepository repository;

  GamificationNotifier(this.repository) : super(const AsyncValue.loading()) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    state = const AsyncValue.loading();
    try {
      final progress = await repository.getUserProgress('current_user');
      state = AsyncValue.data(progress);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> awardPoints(int points, String reason) async {
    await repository.awardPoints('current_user', points, reason);
    await _loadProgress(); // Refresh progress
  }
}

final gamificationNotifierProvider =
    StateNotifierProvider<GamificationNotifier, AsyncValue<UserProgress>>(
        (ref) {
  final repository = ref.watch(gamificationRepositoryProvider);
  return GamificationNotifier(repository);
});
