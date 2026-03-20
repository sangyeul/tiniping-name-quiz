class Character {
  final String id;
  final String name;
  final String nameKo;
  final int season;
  final String category;
  final String grade;
  final String imageFile;
  final String imageUrl;

  const Character({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.season,
    required this.category,
    required this.grade,
    required this.imageFile,
    required this.imageUrl,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKo: json['nameKo'] as String,
      season: json['season'] as int,
      category: json['category'] as String,
      grade: json['grade'] as String,
      imageFile: json['imageFile'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}
