import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/resources_provider.dart';
import '../../../capacity_building/presentation/providers/capacity_building_provider.dart';
import '../../domain/models/resource.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EnhancedResourcesScreen extends ConsumerStatefulWidget {
  const EnhancedResourcesScreen({super.key});

  @override
  ConsumerState<EnhancedResourcesScreen> createState() =>
      _EnhancedResourcesScreenState();
}

class _EnhancedResourcesScreenState
    extends ConsumerState<EnhancedResourcesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final category =
          GoRouterState.of(context).uri.queryParameters['category'];
      if (category != null) {
        ref.read(resourcesProvider.notifier).setCategory(category);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resourcesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Export Resources",
          style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search resources...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(resourcesProvider.notifier)
                                  .setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    ref.read(resourcesProvider.notifier).setSearchQuery(value);
                  },
                ),
              ),

              // Category filters
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip(
                        context, 'All', null, state.selectedCategory),
                    _buildCategoryChip(context, '📜 Registration',
                        'registration-licensing', state.selectedCategory),
                    _buildCategoryChip(context, '📄 Docs',
                        'documentation-procedures', state.selectedCategory),
                    _buildCategoryChip(context, '💰 Financing',
                        'financing-incentives', state.selectedCategory),
                    _buildCategoryChip(context, '✅ Standards',
                        'standards-quality', state.selectedCategory),
                    _buildCategoryChip(context, '📊 Market Intel',
                        'market-intelligence', state.selectedCategory),
                    _buildCategoryChip(context, '🚚 Logistics',
                        'logistics-customs', state.selectedCategory),
                    _buildCategoryChip(context, '🏆 Certificates',
                        'certificates', state.selectedCategory),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (state.selectedCategory == 'certificates') {
            await ref.read(modulesProvider.notifier).fetchModules();
          } else {
            await ref.read(resourcesProvider.notifier).fetchResources();
          }
        },
        child: state.selectedCategory == 'certificates'
            ? _buildCertificatesList()
            : state.isLoading && state.resources.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.resources.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.resources.length,
                        itemBuilder: (context, index) {
                          final resource = state.resources[index];
                          return _buildResourceCard(resource, index);
                        },
                      ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label,
      String? category, String? selectedCategory) {
    final isSelected = category == selectedCategory;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          ref.read(resourcesProvider.notifier).setCategory(category);
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppTheme.primary.withOpacity(0.2),
        checkmarkColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primary : AppTheme.text,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildResourceCard(Resource resource, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openResource(resource),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon based on type
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor(resource.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(resource.type),
                      color: _getTypeColor(resource.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                        if (resource.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            resource.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Bookmark button
                  IconButton(
                    icon: Icon(
                      resource.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color:
                          resource.isBookmarked ? AppTheme.accent : Colors.grey,
                    ),
                    onPressed: () {
                      ref
                          .read(resourcesProvider.notifier)
                          .toggleBookmark(resource.id);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Category and download count
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryLabel(resource.category),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.download_outlined,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${resource.downloadCount} downloads',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),

                  // Type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(resource.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      resource.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(resource.type),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.05);
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 50),
        Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          'No resources found',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Try adjusting your search or filters',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'link':
        return Icons.link;
      case 'video':
        return Icons.play_circle_outline;
      default:
        return Icons.article;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'pdf':
        return Colors.red;
      case 'link':
        return Colors.blue;
      case 'video':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'registration-licensing':
        return 'Registration & Licensing';
      case 'documentation-procedures':
        return 'Documentation & Procedures';
      case 'financing-incentives':
        return 'Financing & Incentives';
      case 'standards-quality':
        return 'Standards & Quality';
      case 'category':
        return 'Market Intelligence & Platforms';
      case 'market-intelligence':
        return 'Market Intel';
      case 'logistics-customs':
        return 'Logistics & Customs';
      default:
        return category;
    }
  }

  Widget _buildCertificatesList() {
    final modulesState = ref.watch(modulesProvider);
    final completedModules =
        modulesState.modules.where((m) => m.isCompleted).toList();

    if (modulesState.isLoading && completedModules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (completedModules.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 50),
          Icon(Icons.workspace_premium_outlined,
              size: 80, color: Colors.amber.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No certificates yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete capacity building modules and pass the final quiz to earn certificates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.go('/capacity-building'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Go to Learning Journey"),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedModules.length,
      itemBuilder: (context, index) {
        final module = completedModules[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shadowColor: Colors.amber.withOpacity(0.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => context.push(
              '/capacity-building/certificate/${module.id}?title=${Uri.encodeComponent(module.title)}',
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.workspace_premium,
                      color: Colors.amber.shade700,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Module Certificate",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          module.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Earned on completion of all lessons",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (100 * index).ms)
            .scale(begin: const Offset(0.95, 0.95));
      },
    );
  }

  Future<void> _openResource(Resource resource) async {
    if (resource.markdownContent != null) {
      context.push('/resources/view', extra: resource);
      return;
    }

    if (resource.fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resource URL not available')),
      );
      return;
    }

    try {
      // Track download
      ref.read(resourcesProvider.notifier).downloadResource(resource.id);

      // Open URL
      final uri = Uri.parse(resource.fileUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open resource')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
