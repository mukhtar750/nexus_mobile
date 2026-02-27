import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/question.dart';
import '../providers/engagement_providers.dart';

class QuestionsTab extends ConsumerWidget {
  final int eventId;

  const QuestionsTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(questionsProvider(eventId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Q&A",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: [
                    const Text("Sort by: "),
                    DropdownButton<String>(
                      value: questionsState.sort,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                            value: 'recent', child: Text('Recent')),
                        DropdownMenuItem(
                            value: 'popular', child: Text('Popular')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          ref
                              .read(questionsProvider(eventId).notifier)
                              .setSort(val);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: questionsState.isLoading && questionsState.questions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(questionsProvider(eventId).notifier)
                        .fetchQuestions(),
                    child: questionsState.questions.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                  child: Text(
                                      "No questions yet. Be the first to ask!")),
                            ],
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                            itemCount: questionsState.questions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final question = questionsState.questions[index];
                              return _QuestionCard(
                                  question: question, eventId: eventId);
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAskQuestionDialog(context, ref),
        label: const Text("Ask Question"),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  void _showAskQuestionDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Ask a Question",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Type your question here...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  ref
                      .read(questionsProvider(eventId).notifier)
                      .postQuestion(controller.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Submit Question"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  final Question question;
  final int eventId;

  const _QuestionCard({required this.question, required this.eventId});

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  question.user?.initials ?? 'U',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                question.user?.name ?? 'Anonymous',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                _timeAgo(question.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(question.content, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  ref
                      .read(questionsProvider(eventId).notifier)
                      .upvote(question.id);
                },
                icon: Icon(
                  question.isUpvotedByMe
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  color:
                      question.isUpvotedByMe ? AppTheme.primary : Colors.grey,
                  size: 20,
                ),
              ),
              Text('${question.upvoteCount}'),
            ],
          ),
        ],
      ),
    );
  }
}
