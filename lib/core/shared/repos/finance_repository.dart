import '../models/transaction_model.dart';
import '../models/alert_item_model.dart';
import '../models/dashboard_summary_model.dart';
import '../enums/app_enums.dart';
import '../../services/local_storage_service.dart';
import '../../utils/financial_calculator.dart';

class FinanceRepository {
  final LocalStorageService _storageService;

  FinanceRepository(this._storageService);

  Future<List<TransactionRecord>> getTransactions({
    TransactionType? typeFilter,
    String? assetId,
  }) async {
    List<TransactionRecord> list = _storageService.getTransactions();
    if (typeFilter != null) {
      list = list.where((t) => t.type == typeFilter).toList();
    }
    if (assetId != null) {
      list = list.where((t) => t.assetId == assetId).toList();
    }
    return list;
  }

  Future<void> addTransaction(TransactionRecord transaction) async {
    _storageService.addTransaction(transaction);
  }

  Future<List<AlertItem>> getAlerts() async {
    return _storageService.getAlerts();
  }

  Future<void> dismissAlert(String alertId) async {
    _storageService.dismissAlert(alertId);
  }

  Future<DashboardSummary> getDashboardSummary() async {
    final assets = _storageService.getAssets();
    final partners = _storageService.getShareholders();
    final transactions = _storageService.getTransactions();

    return FinancialCalculator.computeDashboardSummary(
      assets: assets,
      shareholders: partners,
      transactions: transactions,
    );
  }
}
