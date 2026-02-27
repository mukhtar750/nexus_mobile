import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/resources_repository.dart';
import '../../domain/models/resource.dart';

// Repository provider
final resourcesRepositoryProvider = Provider((ref) => ResourcesRepository());

// Resources state
class ResourcesState {
  final bool isLoading;
  final List<Resource> resources;
  final String? selectedCategory;
  final String searchQuery;
  final String? error;
  final Set<int> bookmarkedIds;

  ResourcesState({
    this.isLoading = false,
    this.resources = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.error,
    this.bookmarkedIds = const {},
  });

  ResourcesState copyWith({
    bool? isLoading,
    List<Resource>? resources,
    String? selectedCategory,
    String? searchQuery,
    String? error,
    Set<int>? bookmarkedIds,
  }) {
    return ResourcesState(
      isLoading: isLoading ?? this.isLoading,
      resources: resources ?? this.resources,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
    );
  }
}

// Resources notifier
class ResourcesNotifier extends StateNotifier<ResourcesState> {
  final ResourcesRepository _repository;

  ResourcesNotifier(this._repository) : super(ResourcesState()) {
    fetchResources();
  }

  Future<void> fetchResources() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resources = await _repository.getResources(
        category: state.selectedCategory,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );

      // Update bookmark status
      final updatedResources = resources.map((r) {
        return r.copyWith(isBookmarked: state.bookmarkedIds.contains(r.id));
      }).toList();

      state = state.copyWith(isLoading: false, resources: updatedResources);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setCategory(String? category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    if (category != 'certificates') {
      fetchResources();
    } else {
      // Clear resources so the certificates list can be shown exclusively
      state = state.copyWith(isLoading: false, resources: []);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    // Debounce search - in production, use proper debouncing
    fetchResources();
  }

  Future<void> toggleBookmark(int resourceId) async {
    try {
      final newBookmarks = Set<int>.from(state.bookmarkedIds);
      if (newBookmarks.contains(resourceId)) {
        newBookmarks.remove(resourceId);
      } else {
        newBookmarks.add(resourceId);
      }

      state = state.copyWith(bookmarkedIds: newBookmarks);

      // Update bookmarks in displayed resources
      final updatedResources = state.resources.map((r) {
        if (r.id == resourceId) {
          return r.copyWith(isBookmarked: !r.isBookmarked);
        }
        return r;
      }).toList();

      state = state.copyWith(resources: updatedResources);

      await _repository.toggleBookmark(resourceId);
    } catch (e) {
      // Revert on error
      fetchResources();
    }
  }

  Future<void> downloadResource(int resourceId) async {
    try {
      await _repository.downloadResource(resourceId);
      // Show success feedback (handled in UI)
    } catch (e) {
      state = state.copyWith(error: 'Download failed: ${e.toString()}');
    }
  }
}

// Provider
final resourcesProvider =
    StateNotifierProvider<ResourcesNotifier, ResourcesState>((ref) {
  return ResourcesNotifier(ref.watch(resourcesRepositoryProvider));
});
