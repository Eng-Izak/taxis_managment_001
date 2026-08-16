import 'package:get_it/get_it.dart';
import '../services/local_storage_service.dart';
import '../shared/repos/asset_repository.dart';
import '../shared/repos/partner_repository.dart';
import '../shared/repos/finance_repository.dart';
import '../theming/theme_cubit.dart';
import '../localization/locale_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Services
  final storageService = LocalStorageService();
  getIt.registerSingleton<LocalStorageService>(storageService);

  // Theme & Locale Cubits
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getIt<LocalStorageService>()),
  );

  getIt.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(getIt<LocalStorageService>()),
  );

  // Repositories
  getIt.registerLazySingleton<AssetRepository>(
    () => AssetRepository(getIt<LocalStorageService>()),
  );

  getIt.registerLazySingleton<PartnerRepository>(
    () => PartnerRepository(getIt<LocalStorageService>()),
  );

  getIt.registerLazySingleton<FinanceRepository>(
    () => FinanceRepository(getIt<LocalStorageService>()),
  );
}


