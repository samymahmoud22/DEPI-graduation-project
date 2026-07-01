import 'dart:io';
import '../repositories/text_recognition_repository.dart';

class ReadTextFromImageUseCase {
  final TextRecognitionRepository _repository;

  ReadTextFromImageUseCase(this._repository);

  Future<String> call(File image) {
    return _repository.recognizeText(image);
  }
}
