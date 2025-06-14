// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/todo_provider.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showAbout = false;

  @override
  Widget build(BuildContext context) {
    if (_showAbout) {
      return AboutScreen(onBack: () => setState(() => _showAbout = false));
    }

    final themeProvider = context.watch<ThemeProvider>();
    final todoProvider = context.watch<TodoProvider>();

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
                'Settings',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your experience',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 32),

              // Quick Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Progress',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${todoProvider.completedTasks} tasks completed',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '${todoProvider.boards.length} active boards',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Appearance Section
              _buildSectionHeader(context, 'Appearance', Icons.palette),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildThemeOption(
                      context,
                      themeProvider,
                      'Light Mode',
                      'Clean and bright interface',
                      Icons.light_mode,
                      ThemeMode.light,
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                    _buildThemeOption(
                      context,
                      themeProvider,
                      'Dark Mode',
                      'Easy on the eyes',
                      Icons.dark_mode,
                      ThemeMode.dark,
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                    _buildThemeOption(
                      context,
                      themeProvider,
                      'System Default',
                      'Follow device settings',
                      Icons.brightness_auto,
                      ThemeMode.system,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Data Management Section
              _buildSectionHeader(context, 'Data Management', Icons.storage),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      context,
                      'Export Data',
                      'Download your tasks and boards',
                      Icons.download,
                      () => _showExportDialog(context),
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                    _buildActionTile(
                      context,
                      'Clear Completed Tasks',
                      'Remove all completed tasks',
                      Icons.cleaning_services,
                      () => _showClearCompletedDialog(context),
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                    _buildActionTile(
                      context,
                      'Reset All Data',
                      'Delete all tasks and boards',
                      Icons.delete_forever,
                      () => _showResetDialog(context),
                      isDestructive: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Support Section
              _buildSectionHeader(context, 'Support & Info', Icons.help),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      context,
                      'About',
                      'App version and information',
                      Icons.info_outline,
                      () => setState(() => _showAbout = true),
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                    _buildActionTile(
                      context,
                      'Privacy Policy',
                      'How we handle your data',
                      Icons.privacy_tip,
                      () => _showPrivacyDialog(context),
                    ),
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                    ),
                    _buildActionTile(
                      context,
                      'Send Feedback',
                      'Help us improve the app',
                      Icons.feedback,
                      () => _showFeedbackDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // App Version
              Center(
                child: Text(
                  'Todo App v1.0.0',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    String title,
    String subtitle,
    IconData icon,
    ThemeMode mode,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected 
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () => themeProvider.setThemeMode(mode),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive 
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
              ? Theme.of(context).colorScheme.error.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive 
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Export Data'),
        content: const Text(
          'This feature will export all your tasks and boards to a JSON file. '
          'This feature is coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context) {
    final todoProvider = context.read<TodoProvider>();
    final completedCount = todoProvider.completedTasks;
    
    if (completedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No completed tasks to clear')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Completed Tasks'),
        content: Text(
          'This will permanently delete $completedCount completed tasks. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              todoProvider.clearCompletedTasks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cleared $completedCount completed tasks')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset All Data'),
        content: const Text(
          '⚠️ This will permanently delete ALL your tasks and boards. '
          'This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TodoProvider>().resetAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data has been reset')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This app stores all data locally on your device. '
            'No personal information is collected or transmitted to external servers. '
            'Your privacy is our priority.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send Feedback'),
        content: const Text(
          'We\'d love to hear from you! This feature will be available soon. '
          'Thank you for using our app!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thanks!'),
          ),
        ],
      ),
    );
  }
}