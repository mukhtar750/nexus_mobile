class Question {
  final int id;
  final String text;
  final String category;
  final List<String> options;
  final List<int> scores; // Corresponding score for each option

  Question({
    required this.id,
    required this.text,
    required this.category,
    required this.options,
    required this.scores,
  });
}
