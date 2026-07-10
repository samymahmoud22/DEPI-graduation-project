import 'dart:io';
import '../../../../core/data/datasources/gemini_remote_datasource.dart';
import '../../domain/repositories/text_recognition_repository.dart';

class TextRecognitionRepositoryImpl implements TextRecognitionRepository {
  final GeminiRemoteDataSource _geminiRemoteDataSource;

  TextRecognitionRepositoryImpl(this._geminiRemoteDataSource);

  @override
  Future<String> recognizeText(File image) async {
    const prompt = 'Perform OCR on this image. Extract all text from it in its original language (Arabic, English, etc.). Do not add any conversational text or commentary. Return only the extracted text. If no text is found, return "No text detected."';
    return _geminiRemoteDataSource.analyzeImageAndText(
      prompt: prompt,
      image: image,
    );
  }
}
