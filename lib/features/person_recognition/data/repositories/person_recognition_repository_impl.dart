import 'dart:io';
import '../../../../core/data/datasources/gemini_remote_datasource.dart';
import '../../domain/entities/person_entity.dart';
import '../../domain/repositories/person_recognition_repository.dart';
import '../datasources/person_local_datasource.dart';
import '../models/person_model.dart';

class PersonRecognitionRepositoryImpl implements PersonRecognitionRepository {
  final PersonLocalDataSource _localDataSource;
  final GeminiRemoteDataSource _geminiRemoteDataSource;

  PersonRecognitionRepositoryImpl({
    required PersonLocalDataSource localDataSource,
    required GeminiRemoteDataSource geminiRemoteDataSource,
  })  : _localDataSource = localDataSource,
        _geminiRemoteDataSource = geminiRemoteDataSource;

  @override
  Future<List<PersonEntity>> getRegisteredPersons() async {
    return await _localDataSource.getRegisteredPersons();
  }

  @override
  Future<void> registerPerson(PersonEntity person) async {
    final model = PersonModel.fromEntity(person);
    await _localDataSource.savePerson(model);
  }

  @override
  Future<void> deletePerson(String id) async {
    await _localDataSource.deletePerson(id);
  }

  @override
  Future<String> recognizePerson(File imageFile) async {
    try {
      final registered = await _localDataSource.getRegisteredPersons();

      if (registered.isEmpty) {
        const prompt = 'Analyze this image and describe the person in it in Arabic '
            '(mention gender, approximate age, clothing, facial expression, and any notable details). '
            'Start your response with "UNKNOWN: " in English, followed by the description in Arabic.';
        return await _geminiRemoteDataSource.analyzeImageAndText(
          prompt: prompt,
          image: imageFile,
        );
      }

      // Prepare images list: Reference images first, and target captured image last
      final List<File> imagesList = [];
      final buffer = StringBuffer();
      
      buffer.writeln('You are an AI assistant helping a blind user identify people.');
      buffer.writeln('The last image in the list is the target captured face of a person standing in front of the user.');
      buffer.writeln('The preceding images are reference photos of registered known people:');

      for (int i = 0; i < registered.length; i++) {
        final person = registered[i];
        final refFile = File(person.imagePath);
        if (await refFile.exists()) {
          imagesList.add(refFile);
          buffer.writeln('Image ${imagesList.length}: Name: ${person.name}, Age: ${person.age}, Job: ${person.jobTitle}, Details: ${person.bio}');
        } else {
          // If reference image file is missing, still pass info to Gemini text context
          buffer.writeln('(Reference photo missing) Name: ${person.name}, Age: ${person.age}, Job: ${person.jobTitle}, Details: ${person.bio}');
        }
      }

      // Add the target image at the very end
      imagesList.add(imageFile);
      final targetIndex = imagesList.length;
      
      buffer.writeln('\nInstructions:');
      buffer.writeln('1. Compare the target captured image (Image $targetIndex) with the reference images of registered people (Images 1 to ${targetIndex - 1}).');
      buffer.writeln('2. If the person in the target image matches one of the registered people, respond in Arabic starting exactly with "MATCHED: " followed by the person\'s name, and then a natural sounding Arabic text describing them so it can be read aloud, for example:');
      buffer.writeln('"MATCHED: [Name]\nهذا هو [Name]، عمره [Age] عاماً، ويعمل [JobTitle]، وهو [Bio]"');
      buffer.writeln('3. If the person does NOT match any registered person, analyze the target image and briefly describe the person in Arabic (gender, approximate age, clothing, expression). Start this response with "UNKNOWN: " in English, for example:');
      buffer.writeln('"UNKNOWN: شخص غريب غير مسجل، يبدو أنه شاب في العشرينات يرتدي نظارة ويبتسم"');
      buffer.writeln('4. Respond ONLY with the match result or description. Do not add any extra conversational text or commentary.');

      return await _geminiRemoteDataSource.analyzeMultipleImagesAndText(
        prompt: buffer.toString(),
        images: imagesList,
      );
    } catch (e) {
      return 'Error: $e';
    }
  }
}
