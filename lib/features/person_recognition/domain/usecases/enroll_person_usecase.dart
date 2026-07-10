import '../../domain/entities/person_entity.dart';
import '../../domain/repositories/person_recognition_repository.dart';

class EnrollPersonUseCase {
  final PersonRecognitionRepository _repository;

  EnrollPersonUseCase(this._repository);

  Future<void> call(PersonEntity person) async {
    return await _repository.registerPerson(person);
  }
}
