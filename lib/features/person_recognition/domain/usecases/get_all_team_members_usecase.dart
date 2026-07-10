import '../../domain/entities/person_entity.dart';
import '../../domain/repositories/person_recognition_repository.dart';

class GetAllTeamMembersUseCase {
  final PersonRecognitionRepository _repository;

  GetAllTeamMembersUseCase(this._repository);

  Future<List<PersonEntity>> call() async {
    return await _repository.getRegisteredPersons();
  }
}
