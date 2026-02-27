import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../profile/presentation/providers/user_provider.dart';

class AssessmentResultScreen extends ConsumerStatefulWidget {
  final int score;

  const AssessmentResultScreen({super.key, required this.score});

  @override
  ConsumerState<AssessmentResultScreen> createState() =>
      _AssessmentResultScreenState();
}

class _AssessmentResultScreenState
    extends ConsumerState<AssessmentResultScreen> {
  bool _isSaved = false;

  String get _readinessCategory {
    if (widget.score > 450) return "Advanced Exporter";
    if (widget.score > 300) return "Export-Ready";
    if (widget.score > 150) return "Developing";
    return "Foundational";
  }

  String get _analyticalSegment {
    final user = ref.read(userProvider).user;
    final exportedBefore = user?.exportedBefore ?? false;

    if (exportedBefore) {
      return widget.score > 450 ? "Active Exporter" : "Occasional Exporter";
    } else {
      return widget.score > 350 ? "Export-Ready SME" : "Developing SME";
    }
  }

  String get _resultDescription {
    final category = _readinessCategory;
    switch (category) {
      case "Advanced Exporter":
        return "Optimized systems. Your business is ready for high-volume orders and complex market regulations.";
      case "Export-Ready":
        return "Strong operations! You are ready to engage with international buyers and logistics providers.";
      case "Developing":
        return "You have a solid foundation but need to address key areas in GMP and branding before scaling exports.";
      case "Foundational":
      default:
        return "You are in the early stages of your export journey. Focus on business registration and facility setup first.";
    }
  }

  Color get _resultColor {
    final category = _readinessCategory;
    switch (category) {
      case "Advanced Exporter":
        return AppTheme.success;
      case "Export-Ready":
        return AppTheme.primary;
      case "Developing":
        return Colors.orange;
      case "Foundational":
      default:
        return Colors.red;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSaved) {
      _saveResults();
      _isSaved = true;
    }
  }

  void _saveResults() {
    Future.microtask(() {
      ref.read(userProvider.notifier).setAssessmentCompleted(
            readinessCategory: _readinessCategory,
            analyticalSegment: _analyticalSegment,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final category = _readinessCategory;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Readiness Result"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: _resultColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _resultColor, width: 4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.score}",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _resultColor,
                        ),
                      ),
                      Text(
                        "OF 520",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _resultColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _resultColor,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _resultDescription,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Segment Insight (Institutional Insight)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: Colors.blueGrey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Institutional Segment",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _analyticalSegment,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Performance Bar Chart
            _buildPerformanceSnapshot(),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/capacity-building'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Start Recommended Learning 🚀",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Dashboard'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSnapshot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Readiness Snapshot",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 16),
        _buildScoreBar("Foundational", 150),
        _buildScoreBar("Developing", 300),
        _buildScoreBar("Export-Ready", 450),
        _buildScoreBar("Advanced", 520),
      ],
    );
  }

  Widget _buildScoreBar(String label, int max) {
    final bool isCurrent = widget.score <= max &&
        (max == 150 ||
            widget.score > (max == 300 ? 150 : (max == 450 ? 300 : 450)));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? AppTheme.text : Colors.grey,
                ),
              ),
              if (isCurrent)
                const Icon(Icons.check_circle,
                    size: 16, color: AppTheme.success),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: widget.score >= max
                  ? 1.0
                  : (widget.score > (max - 150)
                      ? (widget.score - (max - 150)) / 150
                      : 0.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCurrent
                    ? _resultColor
                    : (widget.score >= max
                        ? _resultColor.withOpacity(0.5)
                        : Colors.grey.shade300),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
