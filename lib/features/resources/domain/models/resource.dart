class Resource {
  final int id;
  final String title;
  final String category;
  final String type; // 'pdf', 'link', 'video'
  final String? description;
  final String? fileUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final int downloadCount;
  final String? markdownContent;
  final bool isBookmarked;

  Resource({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    this.description,
    this.fileUrl,
    this.thumbnailUrl,
    this.markdownContent,
    required this.createdAt,
    this.downloadCount = 0,
    this.isBookmarked = false,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      type: json['type'] ?? 'pdf',
      description: json['description'],
      fileUrl: json['file_url'],
      thumbnailUrl: json['thumbnail_url'],
      markdownContent: json['markdown_content'],
      createdAt: DateTime.parse(json['created_at']),
      downloadCount: json['download_count'] ?? 0,
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }

  Resource copyWith({
    int? id,
    String? title,
    String? category,
    String? type,
    String? description,
    String? fileUrl,
    String? thumbnailUrl,
    DateTime? createdAt,
    int? downloadCount,
    bool? isBookmarked,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      markdownContent: markdownContent ?? markdownContent,
      createdAt: createdAt ?? this.createdAt,
      downloadCount: downloadCount ?? this.downloadCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
