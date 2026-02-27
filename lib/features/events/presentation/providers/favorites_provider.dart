import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesNotifier extends StateNotifier<Set<int>> {
  static const _key = 'favorite_events';

  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favorites = prefs.getStringList(_key);
    if (favorites != null) {
      state = favorites.map((id) => int.parse(id)).toSet();
    }
  }

  Future<void> toggleFavorite(int eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final newFavorites = Set<int>.from(state);

    if (newFavorites.contains(eventId)) {
      newFavorites.remove(eventId);
    } else {
      newFavorites.add(eventId);
    }

    state = newFavorites;
    await prefs.setStringList(_key, state.map((id) => id.toString()).toList());
  }

  bool isFavorite(int eventId) => state.contains(eventId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier();
});
