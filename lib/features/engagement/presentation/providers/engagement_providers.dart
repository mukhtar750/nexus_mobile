import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/engagement_repository.dart';
import '../../domain/models/poll.dart';
import '../../domain/models/question.dart';

final engagementRepositoryProvider = Provider((ref) => EngagementRepository());

// Polls State
class PollsState {
  final bool isLoading;
  final List<Poll> polls;
  final String? error;

  PollsState({this.isLoading = false, this.polls = const [], this.error});
}

class PollsNotifier extends StateNotifier<PollsState> {
  final EngagementRepository _repository;
  final int eventId;

  PollsNotifier(this._repository, this.eventId) : super(PollsState()) {
    fetchPolls();
  }

  Future<void> fetchPolls() async {
    state = PollsState(isLoading: true, polls: state.polls);
    try {
      final polls = await _repository.getPolls(eventId);
      state = PollsState(polls: polls);
    } catch (e) {
      state = PollsState(error: e.toString(), polls: state.polls);
    }
  }

  Future<void> vote(int pollId, int optionId) async {
    try {
      await _repository.votePoll(pollId, optionId);
      await fetchPolls();
    } catch (e) {
      state = PollsState(error: e.toString(), polls: state.polls);
    }
  }
}

final pollsProvider = StateNotifierProvider.family<PollsNotifier, PollsState, int>((ref, eventId) {
  return PollsNotifier(ref.watch(engagementRepositoryProvider), eventId);
});

// Questions State
class QuestionsState {
  final bool isLoading;
  final List<Question> questions;
  final String sort;
  final String? error;

  QuestionsState({
    this.isLoading = false,
    this.questions = const [],
    this.sort = 'recent',
    this.error,
  });
}

class QuestionsNotifier extends StateNotifier<QuestionsState> {
  final EngagementRepository _repository;
  final int eventId;

  QuestionsNotifier(this._repository, this.eventId) : super(QuestionsState()) {
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    state = QuestionsState(isLoading: true, questions: state.questions, sort: state.sort);
    try {
      final questions = await _repository.getQuestions(eventId, sort: state.sort);
      state = QuestionsState(questions: questions, sort: state.sort);
    } catch (e) {
      state = QuestionsState(error: e.toString(), questions: state.questions, sort: state.sort);
    }
  }

  Future<void> setSort(String sort) async {
    if (state.sort == sort) return;
    state = QuestionsState(isLoading: true, questions: state.questions, sort: sort);
    await fetchQuestions();
  }

  Future<void> postQuestion(String content) async {
    try {
      await _repository.postQuestion(eventId, content);
      fetchQuestions();
    } catch (e) {
       state = QuestionsState(error: e.toString(), questions: state.questions, sort: state.sort);
    }
  }

  Future<void> upvote(int questionId) async {
      // Optimistic update
      final currentQuestions = state.questions;
      final index = currentQuestions.indexWhere((q) => q.id == questionId);
      if (index != -1) {
          final q = currentQuestions[index];
          final newQ = Question(
              id: q.id,
              eventId: q.eventId,
              userId: q.userId,
              user: q.user,
              content: q.content,
              createdAt: q.createdAt,
              upvoteCount: q.isUpvotedByMe ? q.upvoteCount - 1 : q.upvoteCount + 1,
              isUpvotedByMe: !q.isUpvotedByMe,
          );
          final newQuestions = List<Question>.from(currentQuestions);
          newQuestions[index] = newQ;
          state = QuestionsState(questions: newQuestions, sort: state.sort);
      }

    try {
      await _repository.upvoteQuestion(questionId);
    } catch (e) {
      // Revert on error
      fetchQuestions();
    }
  }
}

final questionsProvider = StateNotifierProvider.family<QuestionsNotifier, QuestionsState, int>((ref, eventId) {
  return QuestionsNotifier(ref.watch(engagementRepositoryProvider), eventId);
});
