import '../entities/history_item_entity.dart';
import '../repositories/history_repository.dart';

class SaveHistoryItemUseCase {
  final HistoryRepository repository;

  SaveHistoryItemUseCase(this.repository);

  Future<void> call(HistoryItemEntity item) async {
    await repository.saveHistoryItem(item);
  }
}
