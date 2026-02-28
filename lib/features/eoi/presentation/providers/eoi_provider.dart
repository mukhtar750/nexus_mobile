import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/eoi_repository.dart';

// ── State ────────────────────────────────────────────────────────────────────

class EoiState {
  final bool isLoading;
  final String? error;
  final bool submitted; // EOI submitted successfully
  final Map<String, dynamic>? statusResult; // result of checkStatus
  final bool registrationComplete; // completeRegistration succeeded

  const EoiState({
    this.isLoading = false,
    this.error,
    this.submitted = false,
    this.statusResult,
    this.registrationComplete = false,
  });

  EoiState copyWith({
    bool? isLoading,
    String? error,
    bool? submitted,
    Map<String, dynamic>? statusResult,
    bool? registrationComplete,
  }) {
    return EoiState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      submitted: submitted ?? this.submitted,
      statusResult: statusResult ?? this.statusResult,
      registrationComplete: registrationComplete ?? this.registrationComplete,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class EoiNotifier extends StateNotifier<EoiState> {
  final EoiRepository _repository;

  EoiNotifier(this._repository) : super(const EoiState());

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> submitEoi(int summitId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.submitEoi(summitId, data);
      state = state.copyWith(isLoading: false, submitted: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _clean(e));
    }
  }

  Future<void> checkStatus(String email, int summitId) async {
    state = state.copyWith(isLoading: true, error: null, statusResult: null);
    try {
      final result = await _repository.checkStatus(email, summitId);
      state = state.copyWith(isLoading: false, statusResult: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _clean(e));
    }
  }

  Future<void> completeRegistration({
    required String token,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.completeRegistration(
          token: token, password: password, phone: phone);
      state = state.copyWith(isLoading: false, registrationComplete: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _clean(e));
    }
  }

  String _clean(Object e) {
    final s = e.toString();
    return s.startsWith('Exception: ') ? s.substring(11) : s;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final eoiRepositoryProvider = Provider<EoiRepository>((ref) => EoiRepository());

final eoiProvider = StateNotifierProvider<EoiNotifier, EoiState>((ref) {
  return EoiNotifier(ref.watch(eoiRepositoryProvider));
});
