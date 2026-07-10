class PersonEntity {
  final String id;
  final String name;
  final int age;
  final String jobTitle;
  final String bio;
  final String imagePath; // Local path to the person's photo

  const PersonEntity({
    required this.id,
    required this.name,
    required this.age,
    required this.jobTitle,
    required this.bio,
    required this.imagePath,
  });
}
