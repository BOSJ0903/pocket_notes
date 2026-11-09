class Plant {
  final int? id;
  final String name;
  final String wateringNotes;

  Plant({this.id, required this.name, required this.wateringNotes});

  // Convert a Plant into a Map for the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'wateringNotes': wateringNotes,
    };
  }

  // Convert a database Map into a Plant
  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'],
      name: map['name'],
      wateringNotes: map['wateringNotes'],
    );
  }
}