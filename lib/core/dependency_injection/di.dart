import 'package:get_it/get_it.dart';
import '../services/local_storage_service.dart';
import '../shared/repos/asset_repository.dart';
import '../shared/repos/partner_repository.dart';
import '../shared/repos/finance_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Services
  final storageService = LocalStorageService();
  getIt.registerSingleton<LocalStorageService>(storageService);

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
