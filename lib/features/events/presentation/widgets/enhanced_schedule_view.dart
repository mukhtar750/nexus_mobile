import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/event.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EnhancedScheduleView extends ConsumerStatefulWidget {
  final Event event;

  const EnhancedScheduleView({super.key, required this.event});

  @override
  ConsumerState<EnhancedScheduleView> createState() =>
      _EnhancedScheduleViewState();
}

class _EnhancedScheduleViewState extends ConsumerState<EnhancedScheduleView> {
  Map<String, List<EventSession>> _sessionsByDay = {};
  int _selectedDayIndex = 0;
  final Set<int> _expandedSessions = {};

  @override
  void initState() {
    super.initState();
    _groupSessionsByDay();
  }

  @override
  void didUpdateWidget(EnhancedScheduleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.id != widget.event.id ||
        oldWidget.event.sessions.length != widget.event.sessions.length) {
      _groupSessionsByDay();
    }
  }

  void _groupSessionsByDay() {
    _sessionsByDay = {};
    for (var session in widget.event.sessions) {
      final dayKey = DateFormat('yyyy-MM-dd').format(session.startTime);
      if (!_sessionsByDay.containsKey(dayKey)) {
        _sessionsByDay[dayKey] = [];
      }
      _sessionsByDay[dayKey]!.add(session);
    }

    // Sort sessions within each day by start time
    _sessionsByDay.forEach((key, sessions) {
      sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionsByDay.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Schedule not available yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final days = _sessionsByDay.keys.toList()..sort();
    final userState = ref.watch(userProvider);
    final userType = userState.user?.userType ?? 'guest';

    return Column(
      children: [
        // Day selector tabs
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final dayKey = days[index];
              final date = DateTime.parse(dayKey);
              final isSelected = index == _selectedDayIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.text,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Sessions list for selected day
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _sessionsByDay[days[_selectedDayIndex]]?.length ?? 0,
            itemBuilder: (context, index) {
              final session = _sessionsByDay[days[_selectedDayIndex]]![index];

              // Access control: Exclusive sessions are for 'exporter' only
              final isExclusive = session.userTypeRequired == 'exporter';
              final isLocked = isExclusive && userType != 'exporter';

              final isExpanded = _expandedSessions.contains(session.id);

              return _buildSessionCard(
                  session, isExpanded, index, isLocked, isExclusive);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(EventSession session, bool isExpanded, int index,
      bool isLocked, bool isExclusive) {
    final duration = session.endTime.difference(session.startTime);
    final durationText = '${duration.inHours}h ${duration.inMinutes % 60}m';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isLocked
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("This session is exclusive to Verified Exporters"),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              }
            : () {
                setState(() {
                  if (isExpanded) {
                    _expandedSessions.remove(session.id);
                  } else {
                    _expandedSessions.add(session.id);
                  }
                });
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time and duration
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('h:mm a').format(session.startTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isExclusive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium,
                              size: 12, color: Colors.amber.shade800),
                          const SizedBox(width: 4),
                          Text(
                            "EXCLUSIVE",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Icon(
                    isLocked
                        ? Icons.lock_outline
                        : (isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                    color: isLocked ? Colors.grey : AppTheme.primary,
                    size: isLocked ? 18 : 24,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Session title
              Text(
                session.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey : AppTheme.text,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      session.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

              // Speaker (if available)
              if (session.speaker.isNotEmpty)
                ...([
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            size: 14, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          session.speaker,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ]),

              // Expanded details
              if (isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Additional details when expanded
                _buildDetailRow(
                  Icons.schedule,
                  'Duration',
                  durationText,
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  Icons.login,
                  'Starts',
                  DateFormat('h:mm a').format(session.startTime),
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                  Icons.logout,
                  'Ends',
                  DateFormat('h:mm a').format(session.endTime),
                ),

                if (session.speaker.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          child: Text(
                            session.speaker.isNotEmpty
                                ? session.speaker[0]
                                : '?',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Speaker',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                session.speaker,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.text,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.05);
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
