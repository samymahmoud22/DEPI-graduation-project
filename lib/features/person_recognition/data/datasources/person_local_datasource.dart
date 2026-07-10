import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/person_model.dart';

class PersonLocalDataSource {
  static const String _key = 'registered_persons';

  Future<List<PersonModel>> getRegisteredPersons() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    
    final List<PersonModel> persons = list
        .map((item) => PersonModel.fromJson(json.decode(item) as Map<String, dynamic>))
        .toList();

    return persons;
  }

  Future<void> savePerson(PersonModel person) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    list.removeWhere((element) {
      final decoded = json.decode(element) as Map<String, dynamic>;
      return decoded['id'] == person.id;
    });

    list.add(json.encode(person.toJson()));
    await prefs.setStringList(_key, list);
  }

  Future<void> deletePerson(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    
    list.removeWhere((element) {
      final decoded = json.decode(element) as Map<String, dynamic>;
      return decoded['id'] == id;
    });
    
    await prefs.setStringList(_key, list);
  }
}
