import 'dart:io';
import '../../../../core/data/datasources/gemini_remote_datasource.dart';
import '../../domain/repositories/object_detection_repository.dart';

class ObjectDetectionRepositoryImpl implements ObjectDetectionRepository {
  final GeminiRemoteDataSource _geminiRemoteDataSource;

  ObjectDetectionRepositoryImpl(this._geminiRemoteDataSource);

  @override
  Future<String> detectObject(File image) async {
    const prompt = 'Identify the most prominent object in this image. The output must be extremely brief, just naming the object in the format: "Arabic_name (English_name)", for example "كوب (Cup)" or "طاولة (Table)". Do not add any conversational text or introductory words.';
    return _geminiRemoteDataSource.analyzeImageAndText(
      prompt: prompt,
      image: image,
    );
  }
}
