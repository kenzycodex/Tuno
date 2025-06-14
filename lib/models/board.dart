// lib/models/board.dart
class Board {
  final String id;
  final String name;
  final int colorValue; // Store color as int for easy serialization
  final String iconName; // Icon identifier

  Board({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconName,
  });

  // Create a copy of this board with some fields updated
  Board copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? iconName,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
    );
  }

  // Convert to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconName': iconName,
    };
  }

  // Create from Map for JSON deserialization
  factory Board.fromMap(Map<String, dynamic> map) {
    return Board(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorValue: map['colorValue'] ?? 0xFF6C63FF,
      iconName: map['iconName'] ?? 'dashboard',
    );
  }

  @override
  String toString() {
    return 'Board(id: $id, name: $name, colorValue: $colorValue, iconName: $iconName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Board &&
        other.id == id &&
        other.name == name &&
        other.colorValue == colorValue &&
        other.iconName == iconName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        colorValue.hashCode ^
        iconName.hashCode;
  }
}