import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/invitations_repository.dart';
import '../../domain/models/invitation.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../presentation/providers/events_provider.dart';

// Repository provider
final invitationsRepositoryProvider =
    Provider((ref) => InvitationsRepository());

// Invitations state
class InvitationsState {
  final bool isLoading;
  final List<Invitation> invitations;
  final String? error;

  InvitationsState({
    this.isLoading = false,
    this.invitations = const [],
    this.error,
  });

  int get pendingCount => invitations.where((i) => i.isPending).length;

  InvitationsState copyWith({
    bool? isLoading,
    List<Invitation>? invitations,
    String? error,
  }) {
    return InvitationsState(
      isLoading: isLoading ?? this.isLoading,
      invitations: invitations ?? this.invitations,
      error: error,
    );
  }
}

// Invitations notifier
class InvitationsNotifier extends StateNotifier<InvitationsState> {
  final InvitationsRepository _repository;
  final Ref _ref;

  InvitationsNotifier(this._repository, this._ref) : super(InvitationsState()) {
    fetchInvitations();
  }

  Future<void> fetchInvitations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final invitations = await _repository.getInvitations();
      state = state.copyWith(isLoading: false, invitations: invitations);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> respond(int invitationId, String status) async {
    try {
      await _repository.respondToInvitation(invitationId, status);

      // Update local state optmistically or refetch
      if (status == 'accepted') {
        // If accepted, refresh events so the new ticket shows up
        _ref.invalidate(eventsProvider);
        _ref.read(userProvider.notifier).fetchUser();
      }

      await fetchInvitations();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

// Provider
final invitationsProvider =
    StateNotifierProvider<InvitationsNotifier, InvitationsState>((ref) {
  return InvitationsNotifier(ref.watch(invitationsRepositoryProvider), ref);
});
