import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/history_item_entity.dart';
import '../../domain/usecases/get_history_items_usecase.dart';
import '../../domain/usecases/clear_history_usecase.dart';
import '../../domain/usecases/delete_history_item_usecase.dart';
import '../../../../app/providers.dart';

final historyControllerProvider = ChangeNotifierProvider<HistoryController>((ref) {
  final getHistory = ref.read(getHistoryItemsUseCaseProvider);
  final clearHistory = ref.read(clearHistoryUseCaseProvider);
  final deleteHistoryItem = ref.read(deleteHistoryItemUseCaseProvider);
  return HistoryController(
    getHistoryItemsUseCase: getHistory,
    clearHistoryUseCase: clearHistory,
    deleteHistoryItemUseCase: deleteHistoryItem,
  );
});

class HistoryController extends ChangeNotifier {
  final GetHistoryItemsUseCase _getHistoryItemsUseCase;
  final ClearHistoryUseCase _clearHistoryUseCase;
  final DeleteHistoryItemUseCase _deleteHistoryItemUseCase;

  List<HistoryItemEntity> _items = [];
  List<HistoryItemEntity> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HistoryController({
    required GetHistoryItemsUseCase getHistoryItemsUseCase,
    required ClearHistoryUseCase clearHistoryUseCase,
    required DeleteHistoryItemUseCase deleteHistoryItemUseCase,
  })  : _getHistoryItemsUseCase = getHistoryItemsUseCase,
        _clearHistoryUseCase = clearHistoryUseCase,
        _deleteHistoryItemUseCase = deleteHistoryItemUseCase {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _getHistoryItemsUseCase();
    } catch (e) {
      debugPrint("Error loading history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    await _deleteHistoryItemUseCase(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await _clearHistoryUseCase();
    await loadHistory();
  }
}
