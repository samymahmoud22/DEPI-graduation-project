import 'dart:io';

abstract class ObjectDetectionRepository {
  Future<String> detectObject(File image);
}
