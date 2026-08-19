import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxis_managment_001/l10n/app_localizations.dart';
import '../core/theming/app_theme.dart';
import '../core/theming/theme_cubit.dart';
import '../core/localization/locale_cubit.dart';
import '../core/routing/app_router.dart';
import '../core/dependency_injection/di.dart';
import '../core/sync/sync_cubit.dart';
import '../core/security/logic/app_lock_cubit.dart';
import '../core/security/ui/app_lock_wrapper.dart';
import '../core/shared/repos/asset_repository.dart';
import '../core/shared/repos/partner_repository.dart';
import '../core/shared/repos/finance_repository.dart';
import '../features/home/logic/home_cubit.dart';
import '../features/shareholders/logic/shareholders_cubit.dart';
import '../features/auth/logic/auth_cubit.dart';
import '../features/sync/logic/local_sync_cubit.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => getIt<ThemeCubit>(),
        ),
        BlocProvider<LocaleCubit>(
          create: (_) => getIt<LocaleCubit>(),
        ),
        BlocProvider<SyncCubit>(
          create: (_) => getIt<SyncCubit>(),
        ),
        BlocProvider<LocalSyncCubit>(
          create: (_) => getIt<LocalSyncCubit>()..initPlatformSync(),
        ),
        BlocProvider<AppLockCubit>(
          create: (_) => getIt<AppLockCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => getIt<AuthCubit>(),
        ),
        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(
            assetRepository: getIt<AssetRepository>(),
            financeRepository: getIt<FinanceRepository>(),
          )..loadDashboardData(),
        ),
        BlocProvider<ShareholdersCubit>(
          create: (_) => ShareholdersCubit(
            partnerRepository: getIt<PartnerRepository>(),
          )..loadShareholders(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                routerConfig: AppRouter.router,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                builder: (context, child) {
                  return AppLockWrapper(
                    child: Directionality(
                      textDirection: locale.languageCode == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: child ?? const SizedBox.shrink(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
