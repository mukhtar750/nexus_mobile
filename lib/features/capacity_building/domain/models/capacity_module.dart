class CapacityModule {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final int lessonsCount;
  final int estimatedMinutes;
  final int progress; // 0-100
  final bool isCompleted;
  final List<Lesson> lessons;
  final ModuleQuiz? quiz;

  CapacityModule({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.lessonsCount,
    required this.estimatedMinutes,
    this.progress = 0,
    this.isCompleted = false,
    this.lessons = const [],
    this.quiz,
  });

  CapacityModule copyWith({
    String? id,
    String? title,
    String? description,
    String? iconEmoji,
    int? lessonsCount,
    int? estimatedMinutes,
    int? progress,
    bool? isCompleted,
    List<Lesson>? lessons,
    ModuleQuiz? quiz,
  }) {
    return CapacityModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      lessons: lessons ?? this.lessons,
      quiz: quiz ?? this.quiz,
    );
  }
}

class Lesson {
  final String id;
  final String moduleId;
  final int order;
  final String title;
  final String content; // HTML or Markdown
  final String? videoUrl;
  final int estimatedMinutes;
  final bool isCompleted;
  final bool hasVisualComparison; // Flag for lessons with product comparisons

  Lesson({
    required this.id,
    required this.moduleId,
    required this.order,
    required this.title,
    required this.content,
    this.videoUrl,
    required this.estimatedMinutes,
    this.isCompleted = false,
    this.hasVisualComparison = false,
  });

  Lesson copyWith({
    String? id,
    String? moduleId,
    int? order,
    String? title,
    String? content,
    String? videoUrl,
    int? estimatedMinutes,
    bool? isCompleted,
    bool? hasVisualComparison,
  }) {
    return Lesson(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      order: order ?? this.order,
      title: title ?? this.title,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      hasVisualComparison: hasVisualComparison ?? this.hasVisualComparison,
    );
  }
}

class ModuleQuiz {
  final String id;
  final String moduleId;
  final List<QuizQuestion> questions;
  final int passingScore; // percentage
  final int? userScore;
  final bool isPassed;

  ModuleQuiz({
    required this.id,
    required this.moduleId,
    required this.questions,
    this.passingScore = 70,
    this.userScore,
    this.isPassed = false,
  });

  ModuleQuiz copyWith({
    String? id,
    String? moduleId,
    List<QuizQuestion>? questions,
    int? passingScore,
    int? userScore,
    bool? isPassed,
  }) {
    return ModuleQuiz(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      questions: questions ?? this.questions,
      passingScore: passingScore ?? this.passingScore,
      userScore: userScore ?? this.userScore,
      isPassed: isPassed ?? this.isPassed,
    );
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final int? userAnswerIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.userAnswerIndex,
  });

  bool get isCorrect => userAnswerIndex == correctAnswerIndex;

  QuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    int? userAnswerIndex,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      userAnswerIndex: userAnswerIndex ?? this.userAnswerIndex,
    );
  }
}
