import '../models/shareholder_model.dart';
import '../../services/local_storage_service.dart';

class PartnerRepository {
  final LocalStorageService _storageService;

  PartnerRepository(this._storageService);

  Future<List<ShareholderModel>> getShareholders({String? searchQuery}) async {
    List<ShareholderModel> partners = _storageService.getShareholders();

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      partners = partners.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.phone.contains(query) ||
            p.nationalId.contains(query);
      }).toList();
    }

    return partners;
  }

  Future<ShareholderModel?> getShareholderById(String id) async {
    try {
      return _storageService.getShareholders().firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveShareholder(ShareholderModel shareholder) async {
    final existing = await getShareholderById(shareholder.id);
    if (existing != null) {
      _storageService.updateShareholder(shareholder);
    } else {
      _storageService.addShareholder(shareholder);
    }
  }

  Future<void> archiveShareholder(ShareholderModel shareholder, {String? reason}) async {
    _storageService.archiveShareholder(shareholder, reason: reason);
  }

  Future<void> deleteShareholder(String id) async {
    _storageService.deleteShareholder(id);
  }
}
