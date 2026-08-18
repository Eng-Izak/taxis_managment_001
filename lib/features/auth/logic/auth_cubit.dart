import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/shared/models/user_model.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/cloud_sync_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalStorageService _storageService;
  final CloudSyncService syncService;

  AuthCubit({
    required LocalStorageService storageService,
    required this.syncService,
  })  : _storageService = storageService,
        super(AuthState(
          status: storageService.getCurrentUser() != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
          user: storageService.getCurrentUser(),
        ));

  Future<void> loginWithEmail({
    required String email,
    required String passwordOrPin,
    String? displayName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      final cleanEmail = email.trim().toLowerCase();
      final name = displayName != null && displayName.isNotEmpty
          ? displayName
          : cleanEmail.split('@').first.replaceAll('.', ' ');

      final user = UserModel(
        id: 'usr_${cleanEmail.hashCode.abs()}',
        email: cleanEmail,
        displayName: name,
        phone: '01012345678',
        role: 'مدير الأسطول والمحفظة',
        lastSyncTime: DateTime.now(),
      );

      _storageService.setCurrentUser(user);

      // Trigger cloud sync upon sign-in
      await syncService.syncNow(force: true);

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? phone,
  }) async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(
      displayName: displayName,
      phone: phone,
    );
    _storageService.setCurrentUser(updated);
    emit(state.copyWith(user: updated));
  }

  void toggleAutoSync(bool enabled) {
    if (state.user == null) return;
    final updated = state.user!.copyWith(autoSyncEnabled: enabled);
    _storageService.setCurrentUser(updated);
    emit(state.copyWith(user: updated));
  }

  void refreshUser() {
    final user = _storageService.getCurrentUser();
    emit(state.copyWith(user: user));
  }

  Future<void> logout() async {
    _storageService.setCurrentUser(null);
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
