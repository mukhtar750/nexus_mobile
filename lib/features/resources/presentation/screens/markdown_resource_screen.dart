import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/resource.dart';

class MarkdownResourceScreen extends ConsumerWidget {
  final Resource resource;

  const MarkdownResourceScreen({super.key, required this.resource});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          resource.title,
          style: const TextStyle(
            color: AppTheme.text,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppTheme.text),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.text),
            onPressed: () {
              // TODO: Implement share
            },
          ),
        ],
      ),
      body: Markdown(
        data: resource.markdownContent ?? "# Error\nNo content available.",
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            height: 1.5,
          ),
          h2: const TextStyle(
            color: AppTheme.accent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            height: 1.4,
          ),
          p: const TextStyle(
            color: AppTheme.text,
            fontSize: 16,
            height: 1.6,
          ),
          listBullet: const TextStyle(
            color: AppTheme.primary,
            fontSize: 16,
          ),
          blockquote: const TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
          blockquoteDecoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                  color: AppTheme.primary.withOpacity(0.5), width: 4),
            ),
          ),
        ),
      ),
    );
  }
}
