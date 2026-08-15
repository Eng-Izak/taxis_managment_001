import '../models/asset_model.dart';
import '../enums/app_enums.dart';
import '../../services/local_storage_service.dart';

class AssetRepository {
  final LocalStorageService _storageService;

  AssetRepository(this._storageService);

  Future<List<AssetModel>> getAssets({AssetType? filterType, String? searchQuery}) async {
    List<AssetModel> assets = _storageService.getAssets();

    if (filterType != null) {
      assets = assets.where((a) => a.modelType == filterType).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      assets = assets.where((a) {
        return a.plateNumber.toLowerCase().contains(query) ||
            a.carModelYear.toLowerCase().contains(query) ||
            a.driverOrRenterName.toLowerCase().contains(query) ||
            a.chassisNumber.toLowerCase().contains(query);
      }).toList();
    }

    return assets;
  }

  Future<AssetModel?> getAssetById(String id) async {
    try {
      return _storageService.getAssets().firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAsset(AssetModel asset) async {
    final existing = await getAssetById(asset.id);
    if (existing != null) {
      _storageService.updateAsset(asset);
    } else {
      _storageService.addAsset(asset);
    }
  }

  Future<void> deleteAsset(String id) async {
    _storageService.deleteAsset(id);
  }
}
