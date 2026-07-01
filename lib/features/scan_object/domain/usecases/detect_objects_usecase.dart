import 'dart:io';
import '../repositories/object_detection_repository.dart';

class DetectObjectsUseCase {
  final ObjectDetectionRepository _repository;

  DetectObjectsUseCase(this._repository);

  Future<String> call(File image) {
    return _repository.detectObject(image);
  }
}
