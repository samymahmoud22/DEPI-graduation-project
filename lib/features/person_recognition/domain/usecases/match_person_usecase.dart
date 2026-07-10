import 'dart:io';
import '../../domain/repositories/person_recognition_repository.dart';

class MatchPersonUseCase {
  final PersonRecognitionRepository _repository;

  MatchPersonUseCase(this._repository);

  Future<String> call(File imageFile) async {
    return await _repository.recognizePerson(imageFile);
  }
}
