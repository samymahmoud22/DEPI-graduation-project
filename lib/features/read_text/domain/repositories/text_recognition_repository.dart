import 'dart:io';

abstract class TextRecognitionRepository {
  Future<String> recognizeText(File image);
}
