import '../repositories/history_repository.dart';

class DeleteHistoryItemUseCase {
  final HistoryRepository repository;

  DeleteHistoryItemUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteHistoryItem(id);
  }
}
