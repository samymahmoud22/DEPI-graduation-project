import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart' hide ServerException;
import '../../errors/exceptions.dart';

class GeminiRemoteDataSource {
  final GenerativeModel _model;

  GeminiRemoteDataSource(this._model);

  /// Analyzes image and text prompt using the Gemini model.
  /// Converts the [image] file to [DataPart] (bytes) if provided.
  Future<String> analyzeImageAndText({
    String prompt = '',
    File? image,
  }) async {
    try {
      final contentParts = <Part>[TextPart(prompt)];

      if (image != null) {
        if (!await image.exists()) {
          throw ServerException('Provided image file does not exist at path: ${image.path}');
        }
        
        final bytes = await image.readAsBytes();
        
        // Determine MIME type based on file extension
        final mimeType = _getMimeType(image.path);
        contentParts.add(DataPart(mimeType, bytes));
      }

      final content = [Content.multi(contentParts)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw ServerException('Gemini model returned empty response');
      }

      return response.text!;
    } catch (e) {
      throw ServerException('Gemini API Error: $e');
    }
  }

  /// Analyzes multiple images and text prompt using the Gemini model.
  Future<String> analyzeMultipleImagesAndText({
    String prompt = '',
    List<File> images = const [],
  }) async {
    try {
      final contentParts = <Part>[TextPart(prompt)];

      for (final image in images) {
        if (await image.exists()) {
          final bytes = await image.readAsBytes();
          final mimeType = _getMimeType(image.path);
          contentParts.add(DataPart(mimeType, bytes));
        }
      }

      final content = [Content.multi(contentParts)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        throw ServerException('Gemini model returned empty response');
      }

      return response.text!;
    } catch (e) {
      throw ServerException('Gemini API Error: $e');
    }
  }

  String _getMimeType(String filePath) {
    final lowerPath = filePath.toLowerCase();
    if (lowerPath.endsWith('.png')) {
      return 'image/png';
    } else if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (lowerPath.endsWith('.webp')) {
      return 'image/webp';
    } else if (lowerPath.endsWith('.gif')) {
      return 'image/gif';
    } else {
      // Default fallback
      return 'image/jpeg';
    }
  }
}
