import 'package:get_it/get_it.dart';
import '../services/local_storage_service.dart';
import '../services/cloud_sync_service.dart';
import '../network/sync/discovery/service_discovery_manager.dart';
import '../network/sync/server/local_sync_server.dart';
import '../network/sync/client/local_sync_client.dart';
import '../network/sync/repository/local_sync_repository.dart';
import '../shared/repos/asset_repository.dart';
import '../shared/repos/partner_repository.dart';
import '../shared/repos/finance_repository.dart';
import '../theming/theme_cubit.dart';
import '../localization/locale_cubit.dart';
import '../sync/sync_cubit.dart';
import '../security/logic/app_lock_cubit.dart';
import '../security/services/biometric_service.dart';
import '../../features/auth/logic/auth_cubit.dart';
import '../../features/sync/logic/local_sync_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Storage Service
  final storageService = LocalStorageService();
  await storageService.init();
  getIt.registerSingleton<LocalStorageService>(storageService);

  // Biometric Service
  final biometricService = BiometricService();
  getIt.registerSingleton<BiometricService>(biometricService);

  // Cloud Sync Service
  final syncService = CloudSyncService(storageService);
  getIt.registerSingleton<CloudSyncService>(syncService);

  // Local Network Sync Services & Discovery (mDNS + WebSockets)
  final discoveryManager = ServiceDiscoveryManager();
  getIt.registerSingleton<ServiceDiscoveryManager>(discoveryManager);

  final localSyncServer = LocalSyncServer();
  getIt.registerSingleton<LocalSyncServer>(localSyncServer);

  final localSyncClient = LocalSyncClient(discoveryManager: discoveryManager);
  getIt.registerSingleton<LocalSyncClient>(localSyncClient);

  final localSyncRepository = LocalSyncRepository(storageService);
  getIt.registerSingleton<LocalSyncRepository>(localSyncRepository);

  // Local Sync Cubit
  getIt.registerLazySingleton<LocalSyncCubit>(
    () => LocalSyncCubit(
      discoveryManager: getIt<ServiceDiscoveryManager>(),
      server: getIt<LocalSyncServer>(),
      client: getIt<LocalSyncClient>(),
      repository: getIt<LocalSyncRepository>(),
      storage: getIt<LocalStorageService>(),
    ),
  );

  // Security App Lock Cubit
  getIt.registerLazySingleton<AppLockCubit>(
    () => AppLockCubit(
      getIt<LocalStorageService>(),
      getIt<BiometricService>(),
    ),
  );

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
