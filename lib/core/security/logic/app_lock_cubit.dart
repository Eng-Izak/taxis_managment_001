import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/local_storage_service.dart';
import 'app_lock_state.dart';

class AppLockCubit extends Cubit<AppLockState> {
  final LocalStorageService _storage;
  DateTime? _lastBackgroundedTime;

  AppLockCubit(this._storage)
      : super(AppLockState(
          isLocked: _storage.isSetupCompleted() && _storage.isAutoLockEnabled(),
        ));

  bool get isBiometricEnabled => _storage.isBiometricEnabled();
  bool get isAutoLockEnabled => _storage.isAutoLockEnabled();
  String? get userName => _storage.getCurrentUser()?.displayName;
  String? get userRole => _storage.getCurrentUser()?.role;

  /// Handles digit entry from on-screen keypad or keyboard
  void inputDigit(String digit) {
    if (state.enteredDigits.length >= 4) return;

    final updated = state.enteredDigits + digit;
    emit(state.copyWith(enteredDigits: updated, clearError: true));

    if (updated.length == 4) {
      verifyPin(updated);
    }
  }

  /// Removes the last entered digit
  void deleteDigit() {
    if (state.enteredDigits.isEmpty) return;
    final updated = state.enteredDigits.substring(0, state.enteredDigits.length - 1);
    emit(state.copyWith(enteredDigits: updated, clearError: true));
  }

  /// Clears all entered digits
  void clearDigits() {
    emit(state.copyWith(enteredDigits: '', clearError: true));
  }

  /// Verifies entered 4-digit PIN against stored security PIN
  bool verifyPin([String? pin]) {
    final toCheck = pin ?? state.enteredDigits;
    if (_storage.verifyPin(toCheck)) {
      emit(state.copyWith(
        isLocked: false,
        enteredDigits: '',
        clearError: true,
        failedAttempts: 0,
      ));
      return true;
    } else {
      emit(state.copyWith(
        enteredDigits: '',
        errorMessage: 'رمز PIN غير صحيح - يرجى إعادة المحاولة',
        failedAttempts: state.failedAttempts + 1,
      ));
      return false;
    }
  }

  /// Unlocks using verified biometric authentication
  bool unlockWithBiometrics() {
    if (!_storage.isBiometricEnabled()) return false;

    emit(state.copyWith(
      isLocked: false,
      enteredDigits: '',
      clearError: true,
      failedAttempts: 0,
    ));
    return true;
  }

  /// Manually locks the app session
  void lock() {
    emit(state.copyWith(
      isLocked: true,
      enteredDigits: '',
      clearError: true,
    ));
  }

  /// Called when app is moved to background or paused
  void onAppBackgrounded() {
    _lastBackgroundedTime = DateTime.now();
  }

  /// Called when app is resumed from background
  void onAppResumed() {
    if (state.isLocked) return;
    if (!_storage.isSetupCompleted() || !_storage.isAutoLockEnabled()) return;

    final timeoutMinutes = _storage.getLockTimeoutMinutes();
    if (_lastBackgroundedTime == null) {
      lock();
      return;
    }

    final elapsed = DateTime.now().difference(_lastBackgroundedTime!);
    if (timeoutMinutes == 0 || elapsed.inSeconds >= timeoutMinutes * 60) {
      lock();
    }
  }
}
