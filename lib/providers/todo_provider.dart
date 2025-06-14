// lib/providers/todo_provider.dart - Updated with additional methods
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../models/board.dart';

class TodoProvider with ChangeNotifier {
  final List<Board> _boards = [
    // Sample boards for demonstration
    Board(
      id: '1',
      name: 'Personal',
      colorValue: 0xFF6C63FF,
      iconName: 'home',
    ),
    Board(
      id: '2',
      name: 'Work',
      colorValue: 0xFF4ECDC4,
      iconName: 'work',
    ),
    Board(
      id: '3',
      name: 'Shopping',
      colorValue: 0xFFFF6B6B,
      iconName: 'shopping',
    ),
  ];
  
  final List<Todo> _todos = [
    // Sample todos for demonstration
    Todo(
      id: '1',
      title: 'Buy groceries',
      description: 'Get milk, bread, and eggs from the store',
      boardId: '3',
      priority: 2,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Todo(
      id: '2',
      title: 'Complete project proposal',
      description: 'Finish the quarterly project proposal for client review',
      boardId: '2',
      priority: 1,
      dueDate: DateTime.now().add(const Duration(days: 3)),
    ),
    Todo(
      id: '3',
      title: 'Call dentist',
      description: 'Schedule annual checkup appointment',
      boardId: '1',
      priority: 3,
    ),
    Todo(
      id: '4',
      title: 'Review team reports',
      description: 'Go through all team member progress reports',
      boardId: '2',
      priority: 2,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      isCompleted: true,
    ),
    Todo(
      id: '5',
      title: 'Plan weekend trip',
      description: 'Research destinations and book accommodation',
      boardId: '1',
      priority: 3,
      dueDate: DateTime.now(),
    ),
    Todo(
      id: '6',
      title: 'Gym workout',
      description: 'Cardio and strength training session',
      boardId: '1',
      priority: 2,
      dueDate: DateTime.now(),
    ),
  ];
  
  final _uuid = const Uuid();

  List<Board> get boards => List.unmodifiable(_boards);
  List<Todo> get todos => List.unmodifiable(_todos);

  // Board CRUD operations
  void addBoard(String name, int colorValue, String iconName) {
    if (name.trim().isEmpty) return;
    
    final board = Board(
      id: _uuid.v4(),
      name: name.trim(),
      colorValue: colorValue,
      iconName: iconName,
    );
    _boards.add(board);
    notifyListeners();
  }

  void updateBoard(Board updatedBoard) {
    final index = _boards.indexWhere((b) => b.id == updatedBoard.id);
    if (index != -1) {
      _boards[index] = updatedBoard;
      notifyListeners();
    }
  }

  void deleteBoard(String boardId) {
    _boards.removeWhere((b) => b.id == boardId);
    // Also remove all todos in this board
    _todos.removeWhere((t) => t.boardId == boardId);
    notifyListeners();
  }

  // Todo CRUD operations
  void addTodo(
    String title, 
    String boardId, {
    String? description, 
    DateTime? dueDate, 
    int priority = 2,
  }) {
    if (title.trim().isEmpty) return;
    
    final todo = Todo(
      id: _uuid.v4(),
      title: title.trim(),
      description: description?.trim(),
      dueDate: dueDate,
      priority: priority,
      boardId: boardId,
    );
    _todos.add(todo);
    notifyListeners();
  }

  void updateTodo(Todo updatedTodo) {
    final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      notifyListeners();
    }
  }

  void toggleTodo(String id) {
    final todoIndex = _todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      _todos[todoIndex].completedAt = _todos[todoIndex].isCompleted 
          ? DateTime.now() 
          : null;
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  // Data management operations
  void clearCompletedTasks() {
    _todos.removeWhere((todo) => todo.isCompleted);
    notifyListeners();
  }

  void resetAllData() {
    _todos.clear();
    _boards.clear();
    notifyListeners();
  }

  // Helper methods
  List<Todo> getTodosForBoard(String boardId) {
    return _todos.where((t) => t.boardId == boardId).toList()
      ..sort((a, b) {
        // Sort by completion status first (incomplete first)
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        // Then by priority (high priority first)
        if (a.priority != b.priority) {
          return a.priority.compareTo(b.priority);
        }
        // Then by due date (nearest first)
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        // Finally by creation order (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  Board? getBoardById(String boardId) {
    try {
      return _boards.firstWhere((b) => b.id == boardId);
    } catch (e) {
      return null;
    }
  }

  Todo? getTodoById(String todoId) {
    try {
      return _todos.firstWhere((t) => t.id == todoId);
    } catch (e) {
      return null;
    }
  }

  // Statistics
  int get totalTasks => _todos.length;
  int get completedTasks => _todos.where((t) => t.isCompleted).length;
  int get pendingTasks => _todos.where((t) => !t.isCompleted).length;
  
  List<Todo> get overdueTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _todos.where((t) => 
      !t.isCompleted && 
      t.dueDate != null && 
      DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day).isBefore(today)
    ).toList();
  }

  List<Todo> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _todos.where((t) => 
      !t.isCompleted &&
      t.dueDate != null && 
      DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day).isAtSameMomentAs(today)
    ).toList();
  }

  List<Todo> get upcomingTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _todos.where((t) => 
      !t.isCompleted &&
      t.dueDate != null && 
      DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day).isAfter(today)
    ).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  double getCompletionPercentage(String boardId) {
    final boardTodos = getTodosForBoard(boardId);
    if (boardTodos.isEmpty) return 0.0;
    
    final completed = boardTodos.where((t) => t.isCompleted).length;
    return completed / boardTodos.length;
  }
}