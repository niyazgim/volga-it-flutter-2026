class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

  factory Trip.fromMap(Map<String, dynamic> m) => Trip(
        id: m['id'] as String,
        name: m['name'] as String,
        startDate: DateTime.parse(m['startDate'] as String),
        endDate: DateTime.parse(m['endDate'] as String),
      );

  Trip copyWith({String? name, DateTime? startDate, DateTime? endDate}) => Trip(
        id: id,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );
}
