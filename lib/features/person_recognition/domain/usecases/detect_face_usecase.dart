import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class DetectFaceUseCase {
  Future<bool> call(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();
      return faces.isNotEmpty;
    } catch (e) {
      await faceDetector.close();
      return true; // Fallback to true if ML Kit fails so we don't block the user
    }
  }
}
