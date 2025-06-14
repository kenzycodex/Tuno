// lib/screens/task_list_screen.dart - Fixed to prevent flash error
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/board.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TaskListScreen extends StatelessWidget {
  final Board board;
  final VoidCallback onBack;
  final void Function(Todo) onTaskTap;
  const TaskListScreen({required this.board, required this.onBack, required this.onTaskTap, Key? key}) : super(key: key);

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int priority = 2;
    DateTime? dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Add Task',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('🔴 High')),
                    DropdownMenuItem(value: 2, child: Text('🟡 Medium')),
                    DropdownMenuItem(value: 3, child: Text('🟢 Low')),
                  ],
                  onChanged: (val) => setState(() => priority = val ?? 2),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => dueDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          dueDate != null 
                              ? 'Due: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                              : 'Set Due Date',
                          style: TextStyle(
                            color: dueDate != null 
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
                        if (dueDate != null)
                          IconButton(
                            onPressed: () => setState(() => dueDate = null),
                            icon: const Icon(Icons.clear, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Task title cannot be empty'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                        return;
                      }
                      context.read<TodoProvider>().addTodo(
                        titleController.text.trim(),
                        board.id,
                        description: descController.text.trim().isEmpty 
                            ? null 
                            : descController.text.trim(),
                        dueDate: dueDate,
                        priority: priority,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(board.colorValue),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Task',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work': return Icons.work;
      case 'shopping': return Icons.shopping_cart;
      case 'fitness': return Icons.fitness_center;
      case 'travel': return Icons.flight;
      case 'home': return Icons.home;
      default: return Icons.dashboard;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1: return '🔴 High';
      case 2: return '🟡 Medium';
      case 3: return '🟢 Low';
      default: return '🟡 Medium';
    }
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<TodoProvider>().getTodosForBoard(board.id);
    final completed = todos.where((t) => t.isCompleted).length;
    final progress = todos.isEmpty ? 0.0 : completed / todos.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text(
          board.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(board.colorValue),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(board.colorValue).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(board.colorValue).withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(board.colorValue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(board.iconName),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          board.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$completed of ${todos.length} Tasks',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Color(board.colorValue).withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(board.colorValue)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: TextStyle(
                        color: Color(board.colorValue),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (todos.isNotEmpty)
                      Text(
                        '${todos.length - completed} remaining',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 160,
                          width: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1611224923853-80b023f02d71?auto=format&fit=crop&w=400&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(board.colorValue).withOpacity(0.1),
                                      Color(board.colorValue).withOpacity(0.2),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.task_alt,
                                  size: 64,
                                  color: Color(board.colorValue),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'No tasks yet!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first task to get started',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: GestureDetector(
                              onTap: () => context.read<TodoProvider>().toggleTodo(todo.id),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: todo.isCompleted 
                                        ? Color(board.colorValue)
                                        : Theme.of(context).colorScheme.outline,
                                    width: 2,
                                  ),
                                  color: todo.isCompleted 
                                      ? Color(board.colorValue)
                                      : Colors.transparent,
                                ),
                                child: todo.isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                            title: Text(
                              todo.title,
                              style: TextStyle(
                                decoration: todo.isCompleted 
                                    ? TextDecoration.lineThrough 
                                    : null,
                                color: todo.isCompleted
                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (todo.description != null && todo.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    todo.description!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(todo.priority).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getPriorityText(todo.priority),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getPriorityColor(todo.priority),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (todo.dueDate != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '📅 ${todo.dueDate!.day}/${todo.dueDate!.month}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.secondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                  onTap: () {
                                    // Use addPostFrameCallback to prevent flash error
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      onTaskTap(todo);
                                    });
                                  },
                                ),
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    // Use addPostFrameCallback to prevent flash error
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      _showDeleteConfirmation(context, todo);
                                    });
                                  },
                                ),
                              ],
                            ),
                            onTap: () => onTaskTap(todo),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(board.colorValue),
              Color(board.colorValue).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(board.colorValue).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.green;
      default: return Colors.orange;
    }
  }

  void _showDeleteConfirmation(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TodoProvider>().deleteTodo(todo.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task "${todo.title}" deleted'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}