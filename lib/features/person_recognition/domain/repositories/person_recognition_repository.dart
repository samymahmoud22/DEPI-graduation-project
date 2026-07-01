import 'dart:io';
import '../entities/person_entity.dart';

abstract class PersonRecognitionRepository {
  Future<List<PersonEntity>> getRegisteredPersons();
  Future<void> registerPerson(PersonEntity person);
  Future<void> deletePerson(String id);
  Future<String> recognizePerson(File imageFile);
}
