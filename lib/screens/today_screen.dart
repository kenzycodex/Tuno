// lib/screens/today_screen.dart - Fixed with stable state management
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class TodayScreen extends StatefulWidget {
  final void Function(Todo) onTaskTap;
  const TodayScreen({required this.onTaskTap, Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep the state alive when switching tabs

  void _toggleTask(String taskId) {
    // Use a post-frame callback to ensure smooth state updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TodoProvider>().toggleTodo(taskId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todayTasks = provider.todayTasks;
        final overdueTasks = provider.overdueTasks;
        final upcomingTasks = provider.todos
            .where((t) => !t.isCompleted && 
                         t.dueDate != null && 
                         t.dueDate!.isAfter(DateTime.now()) &&
                         !t.isDueToday)
            .take(5)
            .toList();

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: CustomScrollView(
              key: const PageStorageKey('today_scroll'),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getGreeting(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Today',
                            todayTasks.length.toString(),
                            Icons.today,
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Overdue',
                            overdueTasks.length.toString(),
                            Icons.warning,
                            Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Completed',
                            provider.completedTasks.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Overdue Tasks
                if (overdueTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Overdue Tasks',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final todo = overdueTasks[index];
                        return Padding(
                          padding: EdgeInsets.fromLTRB(24, 0, 24, index == overdueTasks.length - 1 ? 16 : 8),
                          child: _buildTaskCard(context, todo, Colors.red, provider),
                        );
                      },
                      childCount: overdueTasks.length,
                    ),
                  ),
                ],

                // Today's Tasks
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.today,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Today\'s Tasks',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (todayTasks.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(
                      context,
                      'No tasks for today! 🎉',
                      'You\'re all caught up. Time to relax or plan ahead.',
                      Icons.celebration,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final todo = todayTasks[index];
                        return Padding(
                          padding: EdgeInsets.fromLTRB(24, 0, 24, index == todayTasks.length - 1 ? 16 : 8),
                          child: _buildTaskCard(context, todo, Theme.of(context).colorScheme.primary, provider),
                        );
                      },
                      childCount: todayTasks.length,
                    ),
                  ),

                // Upcoming Tasks
                if (upcomingTasks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Upcoming',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final todo = upcomingTasks[index];
                        return Padding(
                          padding: EdgeInsets.fromLTRB(24, 0, 24, index == upcomingTasks.length - 1 ? 32 : 8),
                          child: _buildTaskCard(context, todo, Theme.of(context).colorScheme.secondary, provider),
                        );
                      },
                      childCount: upcomingTasks.length,
                    ),
                  ),
                ],

                // Add some bottom padding for the last item
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Todo todo, Color accentColor, TodoProvider provider) {
    final board = provider.getBoardById(todo.boardId);

    return Container(
      key: ValueKey(todo.id), // Important: Add key for stable widgets
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
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
          onTap: () => _toggleTask(todo.id),
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: todo.isCompleted ? accentColor : accentColor.withOpacity(0.5),
                width: 2,
              ),
              color: todo.isCompleted ? accentColor : Colors.transparent,
            ),
            child: todo.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (board != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(board.colorValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      board.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(board.colorValue),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(todo.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todo.priorityEmoji} ${todo.priorityText}',
                    style: TextStyle(
                      fontSize: 12,
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

  Widget _buildEmptyState(BuildContext context, String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! Let\'s tackle your tasks.';
    if (hour < 17) return 'Good afternoon! Stay productive.';
    return 'Good evening! Finish strong.';
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