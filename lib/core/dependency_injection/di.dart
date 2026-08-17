import 'package:get_it/get_it.dart';
import '../services/local_storage_service.dart';
import '../services/cloud_sync_service.dart';
import '../shared/repos/asset_repository.dart';
import '../shared/repos/partner_repository.dart';
import '../shared/repos/finance_repository.dart';
import '../theming/theme_cubit.dart';
import '../localization/locale_cubit.dart';
import '../sync/sync_cubit.dart';
import '../../features/auth/logic/auth_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Services
  final storageService = LocalStorageService();
  await storageService.init();
  getIt.registerSingleton<LocalStorageService>(storageService);

  final syncService = CloudSyncService(storageService);
  getIt.registerSingleton<CloudSyncService>(syncService);

  // Theme & Locale Cubits
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getIt<LocalStorageService>()),
  );

  getIt.registerLazySingleton<LocaleCubit>(
    () => LocaleCubit(getIt<LocalStorageService>()),
  );

  // Sync & Auth Cubits
  getIt.registerLazySingleton<SyncCubit>(
    () => SyncCubit(
      syncService: getIt<CloudSyncService>(),
      storageService: getIt<LocalStorageService>(),
    ),
  );

  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      storageService: getIt<LocalStorageService>(),
      syncService: getIt<CloudSyncService>(),
    ),
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
