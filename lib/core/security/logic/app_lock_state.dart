class AppLockState {
  final bool isLocked;
  final String enteredDigits;
  final String? errorMessage;
  final bool isBiometricsPromptActive;
  final int failedAttempts;

  const AppLockState({
    required this.isLocked,
    this.enteredDigits = '',
    this.errorMessage,
    this.isBiometricsPromptActive = false,
    this.failedAttempts = 0,
  });

  AppLockState copyWith({
    bool? isLocked,
    String? enteredDigits,
    String? errorMessage,
    bool? isBiometricsPromptActive,
    int? failedAttempts,
    bool clearError = false,
  }) {
    return AppLockState(
      isLocked: isLocked ?? this.isLocked,
      enteredDigits: enteredDigits ?? this.enteredDigits,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isBiometricsPromptActive: isBiometricsPromptActive ?? this.isBiometricsPromptActive,
      failedAttempts: failedAttempts ?? this.failedAttempts,
    );
  }
}
