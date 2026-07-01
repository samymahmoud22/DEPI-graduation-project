import '../../domain/entities/person_entity.dart';

class PersonModel extends PersonEntity {
  const PersonModel({
    required super.id,
    required super.name,
    required super.age,
    required super.jobTitle,
    required super.bio,
    required super.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'jobTitle': jobTitle,
        'bio': bio,
        'imagePath': imagePath,
      };

  factory PersonModel.fromJson(Map<String, dynamic> json) => PersonModel(
        id: json['id'] as String,
        name: json['name'] as String,
        age: json['age'] as int,
        jobTitle: json['jobTitle'] as String,
        bio: json['bio'] as String,
        imagePath: json['imagePath'] as String,
      );

  factory PersonModel.fromEntity(PersonEntity entity) => PersonModel(
        id: entity.id,
        name: entity.name,
        age: entity.age,
        jobTitle: entity.jobTitle,
        bio: entity.bio,
        imagePath: entity.imagePath,
      );
}
