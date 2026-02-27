import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/capacity_building_provider.dart';
import '../widgets/before_after_slider.dart';
import '../widgets/comparison_carousel.dart';
import '../widgets/quiz_dialog.dart';
import '../../data/product_comparison_data.dart';

class ModuleDetailScreen extends ConsumerWidget {
  final String moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currentModuleProvider(moduleId));

    if (state.isLoading && state.module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.module == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Module not found')),
      );
    }

    final module = state.module!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          module.title,
          style: const TextStyle(
              color: AppTheme.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.text),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Module header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      module.iconEmoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${module.lessonsCount} lessons • ${module.estimatedMinutes} minutes',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (module.progress > 0) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: module.progress / 100,
                      minHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${module.progress}% Complete',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Lessons section
          const Text(
            'Lessons',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 12),

          if (module.lessons.isEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Lessons coming soon!',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          ] else ...[
            ...module.lessons
                .map((lesson) => _buildLessonCard(context, lesson, state)),
          ],

          const SizedBox(height: 24),

          // Quiz section
          if (module.quiz != null) ...[
            const Text(
              'Final Quiz',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuizCard(context, module, state),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, lesson, state) {
    final isCompleted =
        state.completedLessons.contains(lesson.id) || lesson.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Show lesson content dialog
          _showLessonDialog(context, lesson, state);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 24)
                      : Text(
                          '${lesson.order}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.estimatedMinutes} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, module, state) {
    final quiz = module.quiz!;
    final hasTaken = quiz.userScore != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (!hasTaken) {
            _showQuizDialog(context, module, state);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: hasTaken && quiz.isPassed
                          ? Colors.green.withOpacity(0.2)
                          : AppTheme.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      hasTaken && quiz.isPassed ? Icons.verified : Icons.quiz,
                      color: hasTaken && quiz.isPassed
                          ? Colors.green
                          : AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Module Quiz',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                        Text(
                          '${quiz.questions.length} questions • ${quiz.passingScore}% to pass',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasTaken) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: quiz.isPassed
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        quiz.isPassed ? Icons.check_circle : Icons.info,
                        color: quiz.isPassed ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quiz.isPassed
                              ? 'Passed with ${quiz.userScore}%! 🎉'
                              : 'Score: ${quiz.userScore}% - Try again',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: quiz.isPassed ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/capacity-building/certificate/${module.id}?title=${Uri.encodeComponent(module.title)}',
                  ),
                  icon: const Icon(Icons.workspace_premium),
                  label: const Text("View Certificate"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _showQuizDialog(context, module, state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Take Quiz',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLessonDialog(BuildContext context, lesson, state) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Markdown content
                      MarkdownBody(
                        data: lesson.content,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          h2: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          h3: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          p: const TextStyle(fontSize: 15, height: 1.6),
                        ),
                      ),

                      // Visual comparisons (if this lesson has them)
                      if (lesson.hasVisualComparison) ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primary.withOpacity(0.2),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.swipe,
                                  color: AppTheme.primary, size: 20),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Interactive Product Comparisons',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Main detailed comparisons
                        ...ProductComparisonData.detailedComparisons.map(
                          (comparison) => Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: BeforeAfterSlider(comparison: comparison),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Quick examples carousel
                        ComparisonCarousel(
                          comparisons: ProductComparisonData.quickExamples,
                        ),

                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: () {
                        ref
                            .read(currentModuleProvider(moduleId).notifier)
                            .markLessonComplete(lesson.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lesson completed! ✓')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Mark as Complete',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuizDialog(BuildContext context, module, state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizDialog(
        moduleId: moduleId,
        quiz: module.quiz!,
      ),
    );
  }
}
