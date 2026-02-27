import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/capacity_building_repository.dart';
import '../../domain/models/capacity_module.dart';
import 'gamification_provider.dart';

// Repository provider
final capacityBuildingRepositoryProvider =
    Provider((ref) => CapacityBuildingRepository());

// Modules state
class ModulesState {
  final bool isLoading;
  final List<CapacityModule> modules;
  final String? error;

  ModulesState({
    this.isLoading = false,
    this.modules = const [],
    this.error,
  });

  ModulesState copyWith({
    bool? isLoading,
    List<CapacityModule>? modules,
    String? error,
  }) {
    return ModulesState(
      isLoading: isLoading ?? this.isLoading,
      modules: modules ?? this.modules,
      error: error,
    );
  }
}

// Modules notifier
class ModulesNotifier extends StateNotifier<ModulesState> {
  final CapacityBuildingRepository _repository;

  ModulesNotifier(this._repository) : super(ModulesState()) {
    fetchModules();
  }

  Future<void> fetchModules() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final modules = await _repository.fetchModules();
      state = state.copyWith(isLoading: false, modules: modules);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Modules provider
final modulesProvider =
    StateNotifierProvider<ModulesNotifier, ModulesState>((ref) {
  return ModulesNotifier(ref.watch(capacityBuildingRepositoryProvider));
});

// Current module state
class CurrentModuleState {
  final bool isLoading;
  final CapacityModule? module;
  final String? error;
  final Set<String> completedLessons;

  CurrentModuleState({
    this.isLoading = false,
    this.module,
    this.error,
    this.completedLessons = const {},
  });

  CurrentModuleState copyWith({
    bool? isLoading,
    CapacityModule? module,
    String? error,
    Set<String>? completedLessons,
  }) {
    return CurrentModuleState(
      isLoading: isLoading ?? this.isLoading,
      module: module ?? this.module,
      error: error,
      completedLessons: completedLessons ?? this.completedLessons,
    );
  }
}

// Current module notifier
class CurrentModuleNotifier extends StateNotifier<CurrentModuleState> {
  final CapacityBuildingRepository _repository;
  final GamificationNotifier? _gamificationNotifier;

  CurrentModuleNotifier(this._repository, [this._gamificationNotifier])
      : super(CurrentModuleState());

  Future<void> loadModule(String moduleId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final module = await _repository.fetchModuleWithDetails(moduleId);
      state = state.copyWith(isLoading: false, module: module);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markLessonComplete(String lessonId) async {
    if (state.module == null) return;

    // Optimistic update
    final newCompleted = Set<String>.from(state.completedLessons)
      ..add(lessonId);
    state = state.copyWith(completedLessons: newCompleted);

    // Update lessons in module
    final updatedLessons = state.module!.lessons.map((lesson) {
      if (lesson.id == lessonId) {
        return lesson.copyWith(isCompleted: true);
      }
      return lesson;
    }).toList();

    final updatedModule = state.module!.copyWith(lessons: updatedLessons);

    // Calculate progress
    final progress =
        (newCompleted.length / updatedLessons.length * 100).round();
    final isCompleted = newCompleted.length == updatedLessons.length;

    state = state.copyWith(
      module: updatedModule.copyWith(
        progress: progress,
        isCompleted: isCompleted,
      ),
    );

    try {
      await _repository.markLessonComplete(state.module!.id, lessonId);
    } catch (e) {
      // Revert on error
      loadModule(state.module!.id);
    }
  }

  Future<int> submitQuiz(List<int> answers) async {
    if (state.module == null || state.module!.quiz == null) return 0;

    try {
      // Calculate score
      final quiz = state.module!.quiz!;
      int correct = 0;
      for (int i = 0; i < answers.length; i++) {
        if (i < quiz.questions.length &&
            answers[i] == quiz.questions[i].correctAnswerIndex) {
          correct++;
        }
      }

      final score = (correct / quiz.questions.length * 100).round();
      final passed = score >= quiz.passingScore;

      // Update quiz with user answers
      final updatedQuestions = List<QuizQuestion>.generate(
        quiz.questions.length,
        (i) => quiz.questions[i].copyWith(
          userAnswerIndex: i < answers.length ? answers[i] : null,
        ),
      );

      final updatedQuiz = quiz.copyWith(
        questions: updatedQuestions,
        userScore: score,
        isPassed: passed,
      );

      final updatedModule = state.module!.copyWith(
        quiz: updatedQuiz,
        isCompleted: passed,
      );

      state = state.copyWith(module: updatedModule);

      await _repository.submitQuiz(state.module!.id, answers);

      // Award points if passed
      if (passed && _gamificationNotifier != null) {
        _gamificationNotifier.awardPoints(
          100, // Fixed 100 points for passing a module quiz
          'Completed ${state.module!.title} Quiz',
        );
      }

      return score;
    } catch (e) {
      return 0;
    }
  }
}

// Current module provider (family)
final currentModuleProvider = StateNotifierProvider.family<
    CurrentModuleNotifier, CurrentModuleState, String>((ref, moduleId) {
  final repository = ref.watch(capacityBuildingRepositoryProvider);
  final gamification = ref.watch(gamificationNotifierProvider.notifier);
  final notifier = CurrentModuleNotifier(repository, gamification);
  notifier.loadModule(moduleId);
  return notifier;
});
