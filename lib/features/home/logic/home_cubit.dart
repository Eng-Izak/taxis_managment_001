import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/shared/repos/asset_repository.dart';
import '../../../core/shared/repos/finance_repository.dart';
import '../../../core/shared/models/asset_model.dart';
import '../../../core/shared/models/document_meta_model.dart';
import '../../../core/shared/models/archived_item_model.dart';
import '../../../core/shared/enums/app_enums.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AssetRepository _assetRepo;
  final FinanceRepository _financeRepo;

  HomeCubit({
    required AssetRepository assetRepository,
    required FinanceRepository financeRepository,
  })  : _assetRepo = assetRepository,
        _financeRepo = financeRepository,
        super(const HomeState());

  Future<void> loadDashboardData() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final summary = await _financeRepo.getDashboardSummary();
      final assets = await _assetRepo.getAssets(
        filterType: state.selectedFilter,
        searchQuery: state.searchQuery,
      );
      final alerts = await _financeRepo.getAlerts();

      emit(state.copyWith(
        status: HomeStatus.success,
        summary: summary,
        assets: assets,
        alerts: alerts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void filterByAssetType(AssetType? type) {
    if (state.selectedFilter == type) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedFilter: type));
    }
    loadDashboardData();
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    loadDashboardData();
  }

  Future<void> addOrUpdateAsset(AssetModel asset) async {
    await _assetRepo.saveAsset(asset);
    await loadDashboardData();
  }

  Future<void> deleteAsset(String assetId) async {
    await _assetRepo.deleteAsset(assetId);
    await loadDashboardData();
  }

  Future<void> archiveAsset(AssetModel asset, {String? reason}) async {
    await _assetRepo.archiveAsset(asset, reason: reason);
    await loadDashboardData();
  }

  Future<bool> restoreArchivedAsset(String archiveId) async {
    final restored = await _assetRepo.restoreArchivedAsset(archiveId);
    if (restored) {
      await loadDashboardData();
    }
    return restored;
  }

  Future<bool> restoreArchivedItem(String archiveId) async {
    final restored = await _assetRepo.restoreArchivedItem(archiveId);
    if (restored) {
      await loadDashboardData();
    }
    return restored;
  }

  Future<void> deleteArchivedPermanently(String archiveId) async {
    await _assetRepo.deleteArchivedPermanently(archiveId);
  }

  Future<List<ArchivedItemModel>> getArchivedItems() async {
    return _assetRepo.getArchivedItems();
  }

  Future<void> addDocumentToAsset(String assetId, DocumentMeta doc) async {
    await _assetRepo.addDocumentToAsset(assetId, doc);
    await loadDashboardData();
  }

  Future<void> dismissAlert(String alertId) async {
    await _financeRepo.dismissAlert(alertId);
    final alerts = await _financeRepo.getAlerts();
    emit(state.copyWith(alerts: alerts));
  }
}
