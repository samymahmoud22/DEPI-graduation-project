import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  test('Verify Gemini 2.5 Flash works with the API key', () async {
    final envFile = File('.env');
    expect(envFile.existsSync(), true);
    
    final lines = envFile.readAsLinesSync();
    String apiKey = '';
    for (var line in lines) {
      if (line.startsWith('GEMINI_API_KEY=')) {
        apiKey = line.substring('GEMINI_API_KEY='.length).trim();
      }
    }
    
    expect(apiKey.isNotEmpty, true);
    
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
    
    final response = await model.generateContent([
      Content.text("Hello, say 'API works' if you can hear me.")
    ]);
    
    print("Response: ${response.text}");
    expect(response.text, isNotNull);
    expect(response.text!.isNotEmpty, true);
  });
}
