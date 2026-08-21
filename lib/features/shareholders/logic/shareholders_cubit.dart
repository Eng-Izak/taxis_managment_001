import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/shared/repos/partner_repository.dart';
import '../../../core/shared/models/shareholder_model.dart';
import '../../../core/services/local_storage_service.dart';
import 'shareholders_state.dart';

class ShareholdersCubit extends Cubit<ShareholdersState> {
  final PartnerRepository _partnerRepo;
  final LocalStorageService? _storage;
  StreamSubscription<void>? _dataChangesSub;

  ShareholdersCubit({
    required PartnerRepository partnerRepository,
    LocalStorageService? storageService,
  })  : _partnerRepo = partnerRepository,
        _storage = storageService,
        super(const ShareholdersState()) {
    if (_storage != null) {
      _dataChangesSub = _storage.dataChanges.listen((_) {
        loadShareholders();
      });
    }
  }

  Future<void> loadShareholders() async {
    emit(state.copyWith(status: ShareholdersStatus.loading));
    try {
      final partners = await _partnerRepo.getShareholders(searchQuery: state.searchQuery);
      emit(state.copyWith(
        status: ShareholdersStatus.success,
        shareholders: partners,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ShareholdersStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    loadShareholders();
  }

  Future<void> addOrUpdateShareholder(ShareholderModel shareholder) async {
    await _partnerRepo.saveShareholder(shareholder);
    await loadShareholders();
  }

  Future<void> archiveShareholder(ShareholderModel shareholder, {String? reason}) async {
    await _partnerRepo.archiveShareholder(shareholder, reason: reason);
    await loadShareholders();
  }

  Future<void> deleteShareholder(String id) async {
    await _partnerRepo.deleteShareholder(id);
    await loadShareholders();
  }

  @override
  Future<void> close() {
    _dataChangesSub?.cancel();
    return super.close();
  }
}
