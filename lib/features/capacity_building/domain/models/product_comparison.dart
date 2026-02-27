class ProductComparison {
  final String title;
  final String beforeLabel;
  final String afterLabel;
  final String beforeDescription;
  final String afterDescription;
  final String? beforeImageUrl; // Will use placeholder for now
  final String? afterImageUrl;
  final List<String> improvements;

  ProductComparison({
    required this.title,
    this.beforeLabel = 'Before',
    this.afterLabel = 'After',
    required this.beforeDescription,
    required this.afterDescription,
    this.beforeImageUrl,
    this.afterImageUrl,
    required this.improvements,
  });
}
