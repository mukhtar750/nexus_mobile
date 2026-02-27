import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/models/summit.dart';
import '../../data/repositories/summits_repository.dart';

// Repository provider
final summitsRepositoryProvider = Provider<SummitsRepository>((ref) {
  return SummitsRepository(Dio());
});

// Summits state
class SummitsState {
  final List<Summit> summits;
  final bool isLoading;
  final String? error;

  SummitsState({
    required this.summits,
    this.isLoading = false,
    this.error,
  });

  SummitsState copyWith({
    List<Summit>? summits,
    bool? isLoading,
    String? error,
  }) {
    return SummitsState(
      summits: summits ?? this.summits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Summits provider
class SummitsNotifier extends StateNotifier<SummitsState> {
  final SummitsRepository _repository;

  SummitsNotifier(this._repository)
      : super(SummitsState(summits: [], isLoading: true)) {
    _loadSummits();
  }

  Future<void> _loadSummits() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final summits = await _repository.getActiveSummits();
      state = state.copyWith(summits: summits, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _loadSummits();
  }
}

final summitsProvider = StateNotifierProvider<SummitsNotifier, SummitsState>(
  (ref) {
    final repository = ref.watch(summitsRepositoryProvider);
    return SummitsNotifier(repository);
  },
);
