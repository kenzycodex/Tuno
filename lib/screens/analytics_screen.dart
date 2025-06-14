// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your productivity and progress',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),

              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total Tasks',
                      provider.totalTasks.toString(),
                      Icons.task,
                      Theme.of(context).colorScheme.primary,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Pending',
                      provider.pendingTasks.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Overdue',
                      provider.overdueTasks.length.toString(),
                      Icons.warning,
                      Colors.red,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Completion Rate
              _buildCompletionRate(context, provider),

              const SizedBox(height: 32),

              // Board Statistics
              _buildBoardStatistics(context, provider),

              const SizedBox(height: 32),

              // Priority Distribution
              _buildPriorityDistribution(context, provider),

              const SizedBox(height: 32),

              // Recent Activity
              _buildRecentActivity(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRate(BuildContext context, TodoProvider provider) {
    final completionRate = provider.totalTasks > 0 
        ? (provider.completedTasks / provider.totalTasks * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Completion Rate',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '$completionRate%',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completionRate / 100,
                        minHeight: 12,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${provider.completedTasks} of ${provider.totalTasks} tasks completed',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoardStatistics(BuildContext context, TodoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.dashboard,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Board Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...provider.boards.map((board) {
            final boardTasks = provider.getTodosForBoard(board.id);
            final completedTasks = boardTasks.where((t) => t.isCompleted).length;
            final progress = boardTasks.isEmpty ? 0.0 : completedTasks / boardTasks.length;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(board.colorValue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconData(board.iconName),
                          color: Color(board.colorValue),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              board.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '$completedTasks/${boardTasks.length} tasks',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(board.colorValue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Color(board.colorValue).withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(board.colorValue)),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriorityDistribution(BuildContext context, TodoProvider provider) {
    final highPriority = provider.todos.where((t) => t.priority == 1 && !t.isCompleted).length;
    final mediumPriority = provider.todos.where((t) => t.priority == 2 && !t.isCompleted).length;
    final lowPriority = provider.todos.where((t) => t.priority == 3 && !t.isCompleted).length;
    final total = highPriority + mediumPriority + lowPriority;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.priority_high,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'Priority Distribution',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildPriorityItem(context, '🔴 High Priority', highPriority, Colors.red, total),
          const SizedBox(height: 12),
          _buildPriorityItem(context, '🟡 Medium Priority', mediumPriority, Colors.orange, total),
          const SizedBox(height: 12),
          _buildPriorityItem(context, '🟢 Low Priority', lowPriority, Colors.green, total),
        ],
      ),
    );
  }

  Widget _buildPriorityItem(BuildContext context, String label, int count, Color color, int total) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            '$count ($percentage%)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, TodoProvider provider) {
    final recentlyCompleted = provider.todos
        .where((t) => t.isCompleted)
        .take(5)
        .toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'Recently Completed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (recentlyCompleted.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No completed tasks yet',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            ...recentlyCompleted.map((todo) {
              final board = provider.getBoardById(todo.boardId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todo.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (board != null)
                            Text(
                              board.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(board.colorValue),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      todo.priorityEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
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
}