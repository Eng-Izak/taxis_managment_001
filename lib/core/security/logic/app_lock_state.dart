class AppLockState {
  final bool isLocked;
  final String enteredDigits;
  final String? errorMessage;
  final bool isBiometricsPromptActive;
  final bool isBiometricAvailable;
  final int failedAttempts;

  const AppLockState({
    required this.isLocked,
    this.enteredDigits = '',
    this.errorMessage,
    this.isBiometricsPromptActive = false,
    this.isBiometricAvailable = true,
    this.failedAttempts = 0,
  });

  AppLockState copyWith({
    bool? isLocked,
    String? enteredDigits,
    String? errorMessage,
    bool? isBiometricsPromptActive,
    bool? isBiometricAvailable,
    int? failedAttempts,
    bool clearError = false,
  }) {
    return AppLockState(
      isLocked: isLocked ?? this.isLocked,
      enteredDigits: enteredDigits ?? this.enteredDigits,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isBiometricsPromptActive: isBiometricsPromptActive ?? this.isBiometricsPromptActive,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}
