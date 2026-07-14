import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart' hide ServerException;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../errors/exceptions.dart';

class GeminiRemoteDataSource {
  final GenerativeModel _model;
  final Dio _dio;

  GeminiRemoteDataSource(this._model, {Dio? dio}) : _dio = dio ?? Dio();

  /// Detects which provider to use based on available API keys.
  /// Priority: OpenRouter > Groq > Google (fallback)
  String _detectProvider() {
    // First check explicit AI_PROVIDER setting
    final explicitProvider = dotenv.env['AI_PROVIDER']?.trim().toLowerCase() ?? '';
    
    // Auto-detect based on key availability (more reliable)
    final openRouterKey = dotenv.env['OPENROUTER_API_KEY']?.trim() ?? '';
    final groqKey = dotenv.env['GROQ_API_KEY']?.trim() ?? '';
    
    debugPrint("===== PROVIDER DETECTION =====");
    debugPrint("Explicit AI_PROVIDER: '$explicitProvider'");
    debugPrint("OPENROUTER_API_KEY length: ${openRouterKey.length}");
    debugPrint("GROQ_API_KEY length: ${groqKey.length}");
    
    String provider;
    
    if (explicitProvider == 'openrouter' && openRouterKey.isNotEmpty) {
      provider = 'openrouter';
    } else if (explicitProvider == 'groq' && groqKey.isNotEmpty) {
      provider = 'groq';
    } else if (openRouterKey.isNotEmpty) {
      // Auto-detect: if OpenRouter key exists, use it
      provider = 'openrouter';
    } else if (groqKey.isNotEmpty) {
      // Auto-detect: if Groq key exists, use it
      provider = 'groq';
    } else {
      provider = 'google';
    }
    
    debugPrint("Selected provider: $provider");
    debugPrint("==============================");
    return provider;
  }

  /// Analyzes image and text prompt using the best available AI provider.
  Future<String> analyzeImageAndText({
    String prompt = '',
    File? image,
  }) async {
    final provider = _detectProvider();
    
    if (provider == 'google') {
      return _analyzeWithGoogle(prompt: prompt, image: image);
    } else {
      return _analyzeWithAlternative(
        provider: provider,
        prompt: prompt,
        images: image != null ? [image] : [],
      );
    }
  }

  /// Analyzes multiple images and text prompt using the best available AI provider.
  Future<String> analyzeMultipleImagesAndText({
    String prompt = '',
    List<File> images = const [],
  }) async {
    final provider = _detectProvider();
    
    if (provider == 'google') {
      return _analyzeMultipleWithGoogle(prompt: prompt, images: images);
    } else {
      return _analyzeWithAlternative(
        provider: provider,
        prompt: prompt,
        images: images,
      );
    }
  }

  /// Native Google SDK implementation for a single image and text
  Future<String> _analyzeWithGoogle({
    required String prompt,
    File? image,
  }) async {
    try {
      final contentParts = <Part>[TextPart(prompt)];

      if (image != null) {
        if (!await image.exists()) {
          throw ServerException('Provided image file does not exist at path: ${image.path}');
        }
        
        final bytes = await image.readAsBytes();
        debugPrint("GeminiDataSource: Image size = ${bytes.length} bytes");
        
        // Determine MIME type based on file extension
        final mimeType = _getMimeType(image.path);
        debugPrint("GeminiDataSource: MIME type = $mimeType");
        contentParts.add(DataPart(mimeType, bytes));
      }

      final content = [Content.multi(contentParts)];
      debugPrint("GeminiDataSource: Sending request to Gemini API...");
      final response = await _model.generateContent(content);
      debugPrint("GeminiDataSource: Response received.");

      if (response.text == null || response.text!.trim().isEmpty) {
        debugPrint("GeminiDataSource: Empty response from Gemini.");
        throw ServerException('Gemini model returned empty response');
      }

      debugPrint("GeminiDataSource: Result = '${response.text!.substring(0, response.text!.length > 100 ? 100 : response.text!.length)}...'");
      return response.text!;
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint("GeminiDataSource ERROR: $e");
      debugPrint("GeminiDataSource STACK: $stackTrace");
      throw ServerException('Gemini API Error: $e');
    }
  }

  /// Native Google SDK implementation for multiple images and text
  Future<String> _analyzeMultipleWithGoogle({
    required String prompt,
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
      debugPrint("GeminiDataSource: Sending multi-image request to Gemini API...");
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.trim().isEmpty) {
        throw ServerException('Gemini model returned empty response');
      }

      return response.text!;
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint("GeminiDataSource ERROR: $e");
      debugPrint("GeminiDataSource STACK: $stackTrace");
      throw ServerException('Gemini API Error: $e');
    }
  }

  /// Alternative API implementation (OpenRouter / Groq) using standard Chat Completions format
  Future<String> _analyzeWithAlternative({
    required String provider,
    required String prompt,
    List<File> images = const [],
  }) async {
    try {
      String apiKey = '';
      String url = '';
      String modelName = '';
      
      if (provider == 'openrouter') {
        apiKey = dotenv.env['OPENROUTER_API_KEY']?.trim() ?? '';
        url = 'https://openrouter.ai/api/v1/chat/completions';
        modelName = dotenv.env['OPENROUTER_MODEL']?.trim() ?? 'google/gemini-flash-1.5:free';
      } else if (provider == 'groq') {
        apiKey = dotenv.env['GROQ_API_KEY']?.trim() ?? '';
        url = 'https://api.groq.com/openai/v1/chat/completions';
        modelName = dotenv.env['GROQ_MODEL']?.trim() ?? 'llama-3.2-11b-vision-preview';
      } else {
        throw ServerException('Unsupported AI Provider: $provider');
      }
      
      if (apiKey.isEmpty) {
        throw ServerException('API Key for $provider is missing in .env');
      }
      
      debugPrint("AlternativeDataSource: Using $provider with model $modelName");
      debugPrint("AlternativeDataSource: API key starts with: ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...");
      
      final contentList = <Map<String, dynamic>>[];
      
      if (prompt.isNotEmpty) {
        contentList.add({
          'type': 'text',
          'text': prompt,
        });
      }
      
      for (final image in images) {
        if (await image.exists()) {
          final bytes = await image.readAsBytes();
          final base64Image = base64Encode(bytes);
          final mimeType = _getMimeType(image.path);
          debugPrint("AlternativeDataSource: Adding image (${bytes.length} bytes, $mimeType)");
          contentList.add({
            'type': 'image_url',
            'image_url': {
              'url': 'data:$mimeType;base64,$base64Image',
            },
          });
        }
      }
      
      final Map<String, dynamic> requestBody = {
        'model': modelName,
        'messages': [
          {
            'role': 'user',
            'content': contentList,
          }
        ],
      };
      
      final Map<String, dynamic> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };
      
      if (provider == 'openrouter') {
        headers['HTTP-Referer'] = 'https://github.com/samymahmoud22/DEPI-graduation-project';
        headers['X-Title'] = 'VisionMate';
      }
      
      debugPrint("AlternativeDataSource: Sending request to $url ...");
      final response = await _dio.post(
        url,
        data: requestBody,
        options: Options(headers: headers),
      );
      debugPrint("AlternativeDataSource: Response status: ${response.statusCode}");
      
      if (response.statusCode != 200) {
        debugPrint("AlternativeDataSource: Error response body: ${response.data}");
        throw ServerException('$provider failed with status ${response.statusCode}: ${response.data}');
      }
      
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final choices = data['choices'];
        if (choices is List && choices.isNotEmpty) {
          final message = choices[0]['message'];
          if (message is Map<String, dynamic>) {
            final content = message['content'] as String?;
            if (content != null && content.isNotEmpty) {
              debugPrint("AlternativeDataSource: Success! Got ${content.length} chars");
              return content;
            }
          }
        }
        // If we got here, the response structure was unexpected
        debugPrint("AlternativeDataSource: Unexpected response: $data");
      }
      
      throw ServerException('Invalid or empty response from $provider');
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint("AlternativeDataSource ERROR: $e");
      debugPrint("AlternativeDataSource STACK: $stackTrace");
      throw ServerException('AI API Error ($provider): $e');
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
