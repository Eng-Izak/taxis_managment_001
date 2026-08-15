import '../../../core/shared/models/asset_model.dart';
import '../../../core/shared/models/dashboard_summary_model.dart';
import '../../../core/shared/models/alert_item_model.dart';
import '../../../core/shared/enums/app_enums.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState {
  final HomeStatus status;
  final DashboardSummary? summary;
  final List<AssetModel> assets;
  final List<AlertItem> alerts;
  final AssetType? selectedFilter;
  final String searchQuery;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.summary,
    this.assets = const [],
    this.alerts = const [],
    this.selectedFilter,
    this.searchQuery = '',
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    DashboardSummary? summary,
    List<AssetModel>? assets,
    List<AlertItem>? alerts,
    AssetType? selectedFilter,
    bool clearFilter = false,
    String? searchQuery,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      assets: assets ?? this.assets,
      alerts: alerts ?? this.alerts,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}
