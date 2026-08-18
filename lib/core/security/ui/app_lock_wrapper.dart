import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/local_storage_service.dart';
import '../../dependency_injection/di.dart';
import '../logic/app_lock_cubit.dart';
import '../logic/app_lock_state.dart';
import 'app_lock_screen.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;

    final cubit = context.read<AppLockCubit>();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      cubit.onAppBackgrounded();
    } else if (state == AppLifecycleState.resumed) {
      cubit.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = getIt<LocalStorageService>();

    return BlocBuilder<AppLockCubit, AppLockState>(
      builder: (context, state) {
        final shouldShowLock = state.isLocked && storage.isSetupCompleted();

        return Stack(
          children: [
            widget.child,
            if (shouldShowLock)
              const Positioned.fill(
                child: AppLockScreen(),
              ),
          ],
        );
      },
    );
  }
}
