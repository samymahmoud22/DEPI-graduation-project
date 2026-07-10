import '../entities/history_item_entity.dart';
import '../repositories/history_repository.dart';

class GetHistoryItemsUseCase {
  final HistoryRepository repository;

  GetHistoryItemsUseCase(this.repository);

  Future<List<HistoryItemEntity>> call() async {
    return await repository.getHistoryItems();
  }
}
