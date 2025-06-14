// lib/screens/task_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/todo.dart';

class TaskDetailScreen extends StatefulWidget {
  final Todo todo;
  final void Function(Todo) onSave;
  final VoidCallback onBack;
  const TaskDetailScreen({required this.todo, required this.onSave, required this.onBack, Key? key}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late int _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descController = TextEditingController(text: widget.todo.description ?? '');
    _priority = widget.todo.priority;
    _dueDate = widget.todo.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Edit Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: _priority,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('🔴 High')),
                      DropdownMenuItem(value: 2, child: Text('🟡 Medium')),
                      DropdownMenuItem(value: 3, child: Text('🟢 Low')),
                    ],
                    onChanged: (val) => setState(() => _priority = val ?? 2),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dueDate != null 
                                  ? 'Due: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                  : 'Set Due Date',
                              style: TextStyle(
                                color: _dueDate != null 
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          if (_dueDate != null)
                            IconButton(
                              onPressed: () => setState(() => _dueDate = null),
                              icon: const Icon(Icons.clear, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task title cannot be empty'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                    return;
                  }
                  final updated = Todo(
                    id: widget.todo.id,
                    title: _titleController.text.trim(),
                    description: _descController.text.trim().isEmpty 
                        ? null 
                        : _descController.text.trim(),
                    dueDate: _dueDate,
                    priority: _priority,
                    boardId: widget.todo.boardId,
                    isCompleted: widget.todo.isCompleted,
                  );
                  widget.onSave(updated);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}