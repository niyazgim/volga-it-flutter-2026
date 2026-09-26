class Category {
  const Category({
    required this.id,
    required this.name,
    this.isStandard = false,
  });

  final String id;
  final String name;
  final bool isStandard;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'isStandard': isStandard,
      };

  factory Category.fromMap(Map<String, dynamic> m) => Category(
        id: m['id'] as String,
        name: m['name'] as String,
        isStandard: (m['isStandard'] as bool?) ?? false,
      );

  Category copyWith({String? name}) =>
      Category(id: id, name: name ?? this.name, isStandard: isStandard);
}
