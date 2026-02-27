import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/poll.dart';
import '../providers/engagement_providers.dart';

class PollsTab extends ConsumerWidget {
  final int eventId;

  const PollsTab({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsState = ref.watch(pollsProvider(eventId));

    if (pollsState.isLoading && pollsState.polls.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pollsState.error != null && pollsState.polls.isEmpty) {
      return Center(child: Text("Error: ${pollsState.error}"));
    }

    if (pollsState.polls.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(pollsProvider(eventId).notifier).fetchPolls(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Center(child: Text("No active polls at the moment.")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(pollsProvider(eventId).notifier).fetchPolls(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: pollsState.polls.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final poll = pollsState.polls[index];
          return _PollCard(poll: poll, eventId: eventId);
        },
      ),
    );
  }
}

class _PollCard extends ConsumerWidget {
  final Poll poll;
  final int eventId;

  const _PollCard({required this.poll, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasVoted = poll.userVotedOptionId != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 16),
          ...poll.options.map((option) {
            final isSelected = poll.userVotedOptionId == option.id;

            if (hasVoted) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(option.optionText,
                            style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        Text('${option.percentage}%'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: option.percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: isSelected ? AppTheme.primary : Colors.grey,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: OutlinedButton(
                  onPressed: () {
                    ref
                        .read(pollsProvider(eventId).notifier)
                        .vote(poll.id, option.id);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    alignment: Alignment.centerLeft,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      option.optionText,
                      style: const TextStyle(color: AppTheme.text),
                    ),
                  ),
                ),
              );
            }
          }),
          if (hasVoted)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${poll.totalVotes} votes',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
