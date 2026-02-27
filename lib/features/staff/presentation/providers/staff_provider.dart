import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/staff_repository.dart';

class StaffState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final Map<String, dynamic>? verificationResult;

  StaffState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.verificationResult,
  });

  StaffState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    Map<String, dynamic>? verificationResult,
  }) {
    return StaffState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      verificationResult: verificationResult,
    );
  }
}

class StaffNotifier extends StateNotifier<StaffState> {
  final StaffRepository _repository;

  StaffNotifier(this._repository) : super(StaffState());

  Future<void> verifyTicket(String ticketCode) async {
    state = state.copyWith(
        isLoading: true,
        error: null,
        successMessage: null,
        verificationResult: null);
    try {
      final result = await _repository.verifyTicket(ticketCode);
      state = state.copyWith(
        isLoading: false,
        successMessage: "Ticket Verified Successfully",
        verificationResult: result,
      );
    } catch (e) {
      final message = e.toString();
      const prefix = 'Exception: ';
      final friendly = message.startsWith(prefix)
          ? message.substring(prefix.length)
          : message;
      state = state.copyWith(
        isLoading: false,
        error: friendly.isEmpty
            ? 'Unable to verify ticket. Please try again.'
            : friendly,
      );
    }
  }

  void reset() {
    state = StaffState();
  }
}

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository();
});

final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>((ref) {
  final repository = ref.watch(staffRepositoryProvider);
  return StaffNotifier(repository);
});
