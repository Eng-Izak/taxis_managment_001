import '../../../core/shared/models/shareholder_model.dart';

enum ShareholdersStatus { initial, loading, success, error }

class ShareholdersState {
  final ShareholdersStatus status;
  final List<ShareholderModel> shareholders;
  final String searchQuery;
  final String? errorMessage;

  const ShareholdersState({
    this.status = ShareholdersStatus.initial,
    this.shareholders = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  ShareholdersState copyWith({
    ShareholdersStatus? status,
    List<ShareholderModel>? shareholders,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ShareholdersState(
      status: status ?? this.status,
      shareholders: shareholders ?? this.shareholders,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}
