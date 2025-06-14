// lib/models/todo.dart
class Todo {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priority; // 1=High, 2=Medium, 3=Low
  final String boardId;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 2,
    required this.boardId,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Create a copy of this todo with some fields updated
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? priority,
    String? boardId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      boardId: boardId ?? this.boardId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Convert to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
      'boardId': boardId,
      'isCompleted': isCompleted,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  // Create from Map for JSON deserialization
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      dueDate: map['dueDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      priority: map['priority'] ?? 2,
      boardId: map['boardId'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
          : null,
    );
  }

  // Helper methods
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return dueDay.isBefore(today);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return dueDay.isAtSameMomentAs(today);
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return dueDay.isAtSameMomentAs(tomorrow);
  }

  String get priorityText {
    switch (priority) {
      case 1: return 'High';
      case 2: return 'Medium';
      case 3: return 'Low';
      default: return 'Medium';
    }
  }

  String get priorityEmoji {
    switch (priority) {
      case 1: return '🔴';
      case 2: return '🟡';
      case 3: return '🟢';
      default: return '🟡';
    }
  }

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, priority: $priority, isCompleted: $isCompleted, boardId: $boardId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.priority == priority &&
        other.boardId == boardId &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        dueDate.hashCode ^
        priority.hashCode ^
        boardId.hashCode ^
        isCompleted.hashCode;
  }
}