import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taxis_managment_001/l10n/app_localizations.dart';
import '../core/theming/app_theme.dart';
import '../core/theming/theme_cubit.dart';
import '../core/routing/app_router.dart';
import '../core/dependency_injection/di.dart';
import '../core/shared/repos/asset_repository.dart';
import '../core/shared/repos/partner_repository.dart';
import '../core/shared/repos/finance_repository.dart';
import '../features/home/logic/home_cubit.dart';
import '../features/shareholders/logic/shareholders_cubit.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => getIt<ThemeCubit>(),
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
          return MaterialApp.router(
            title: 'إدارة أصول تاكسيات مدينة السادات',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
            locale: const Locale('ar', 'EG'), // Arabic (Egypt) RTL as default
            supportedLocales: const [Locale('ar', 'EG'), Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
