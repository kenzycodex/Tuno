// lib/screens/calendar_screen.dart - Fully responsive and fixed
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class CalendarScreen extends StatefulWidget {
  final void Function(Todo) onTaskTap;
  const CalendarScreen({required this.onTaskTap, Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> 
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleTask(String taskId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TodoProvider>().toggleTodo(taskId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final selectedDateTasks = provider.todos.where((todo) {
          if (todo.dueDate == null) return false;
          final taskDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
          final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
          return taskDate.isAtSameMomentAs(selected);
        }).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                final isCompact = screenHeight < 600;
                
                return Column(
                  children: [
                    // Header - Fixed height
                    Container(
                      height: isCompact ? 80 : 100,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Calendar',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isCompact ? 24 : 28,
                                  ),
                                ),
                                if (!isCompact) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Track your tasks by date',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => setState(() {
                                _selectedDate = DateTime.now();
                                _focusedDate = DateTime.now();
                              }),
                              icon: const Icon(Icons.today),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Calendar - Flexible height
                    Flexible(
                      flex: isCompact ? 3 : 4,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.05),
                              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _buildCalendar(provider, isCompact),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tasks Section Header - Fixed height
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tasks for ${_formatDate(_selectedDate)}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isCompact ? 16 : 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (selectedDateTasks.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${selectedDateTasks.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Tasks List - Flexible remaining space
                    Flexible(
                      flex: isCompact ? 2 : 3,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: selectedDateTasks.isEmpty
                            ? _buildEmptyState(isCompact)
                            : ListView.builder(
                                key: PageStorageKey('calendar_tasks_${_selectedDate.millisecondsSinceEpoch}'),
                                padding: const EdgeInsets.only(top: 8, bottom: 20),
                                itemCount: selectedDateTasks.length,
                                itemBuilder: (context, index) {
                                  final todo = selectedDateTasks[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: isCompact ? 8 : 12),
                                    child: _buildTaskCard(todo, provider, isCompact),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendar(TodoProvider provider, bool isCompact) {
    return Padding(
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      child: Column(
        children: [
          // Month/Year Header
          SizedBox(
            height: isCompact ? 40 : 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _formatMonthYear(_focusedDate),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 16 : 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNavButton(Icons.chevron_left, () => setState(() {
                      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                    }), isCompact),
                    SizedBox(width: isCompact ? 4 : 8),
                    _buildNavButton(Icons.chevron_right, () => setState(() {
                      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                    }), isCompact),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: isCompact ? 8 : 12),
          
          // Weekdays
          SizedBox(
            height: isCompact ? 25 : 30,
            child: Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: isCompact ? 11 : 12,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Calendar Grid
          Expanded(
            child: Column(
              children: _buildCalendarWeeks(provider, isCompact),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed, bool isCompact) {
    return Container(
      width: isCompact ? 32 : 36,
      height: isCompact ? 32 : 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: isCompact ? 16 : 18,
        padding: EdgeInsets.zero,
      ),
    );
  }

  List<Widget> _buildCalendarWeeks(TodoProvider provider, bool isCompact) {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday % 7;
    
    final weeks = <Widget>[];
    var currentDate = firstDayOfMonth.subtract(Duration(days: firstDayOfWeek));
    
    while (currentDate.isBefore(lastDayOfMonth) || currentDate.month == _focusedDate.month) {
      final weekDays = <Widget>[];
      
      for (int i = 0; i < 7; i++) {
        final dayTasks = provider.todos.where((todo) {
          if (todo.dueDate == null) return false;
          final taskDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
          final checkDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
          return taskDate.isAtSameMomentAs(checkDate);
        }).toList();
        
        weekDays.add(_buildCalendarDay(currentDate, dayTasks, isCompact));
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      weeks.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: isCompact ? 1 : 2),
            child: Row(children: weekDays),
          ),
        ),
      );
      
      if (currentDate.month != _focusedDate.month && weeks.length >= 6) break;
    }
    
    return weeks;
  }

  Widget _buildCalendarDay(DateTime date, List<Todo> tasks, bool isCompact) {
    final isSelected = date.day == _selectedDate.day && 
                      date.month == _selectedDate.month && 
                      date.year == _selectedDate.year;
    final isToday = date.day == DateTime.now().day && 
                   date.month == DateTime.now().month && 
                   date.year == DateTime.now().year;
    final isCurrentMonth = date.month == _focusedDate.month;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Container(
          height: isCompact ? 32 : 40,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            gradient: isSelected ? LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ) : null,
            color: !isSelected && isToday 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday && !isSelected
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
                : null,
            boxShadow: isSelected ? [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isCompact ? 12 : 14,
                    color: isSelected
                        ? Colors.white
                        : isCurrentMonth
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
              if (tasks.isNotEmpty)
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: isCompact ? 4 : 5,
                        height: isCompact ? 4 : 5,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (tasks.length > 1) ...[
                        const SizedBox(width: 2),
                        Container(
                          width: isCompact ? 3 : 4,
                          height: isCompact ? 3 : 4,
                          decoration: BoxDecoration(
                            color: (isSelected 
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary).withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Todo todo, TodoProvider provider, bool isCompact) {
    final board = provider.getBoardById(todo.boardId);
    
    return Container(
      key: ValueKey(todo.id),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(isCompact ? 12 : 16),
        leading: GestureDetector(
          onTap: () => _toggleTask(todo.id),
          child: Container(
            width: isCompact ? 20 : 24,
            height: isCompact ? 20 : 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: todo.isCompleted 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: 2,
              ),
              color: todo.isCompleted 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
            ),
            child: todo.isCompleted
                ? Icon(Icons.check, color: Colors.white, size: isCompact ? 12 : 16)
                : null,
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 14 : 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null && todo.description!.isNotEmpty) ...[
              SizedBox(height: isCompact ? 2 : 4),
              Text(
                todo.description!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: isCompact ? 12 : 14,
                ),
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: isCompact ? 4 : 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (board != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 6 : 8, 
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Color(board.colorValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      board.name,
                      style: TextStyle(
                        fontSize: isCompact ? 10 : 11,
                        color: Color(board.colorValue),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 6 : 8, 
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(todo.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${todo.priorityEmoji} ${todo.priorityText}',
                    style: TextStyle(
                      fontSize: isCompact ? 10 : 11,
                      color: _getPriorityColor(todo.priority),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => widget.onTaskTap(todo),
      ),
    );
  }

  Widget _buildEmptyState(bool isCompact) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isCompact ? 60 : 80,
              height: isCompact ? 60 : 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.event_available,
                size: isCompact ? 32 : 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: isCompact ? 12 : 16),
            Text(
              'No tasks scheduled',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isCompact ? 14 : 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isCompact ? 4 : 6),
            Text(
              'This date is free of tasks',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: isCompact ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.green;
      default: return Colors.orange;
    }
  }
}