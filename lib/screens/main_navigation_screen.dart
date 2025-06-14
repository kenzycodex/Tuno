// lib/screens/main_navigation_screen.dart - Complete fixed version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/board.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import 'home_screen.dart';
import 'today_screen.dart';
import 'calendar_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'task_list_screen.dart';
import 'task_detail_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Board? _selectedBoard;
  Todo? _selectedTodo;
  
  late PageController _pageController;
  late AnimationController _navAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _navAnimation;
  late Animation<double> _fabAnimation;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.today_outlined,
      activeIcon: Icons.today,
      label: 'Today',
    ),
    NavigationItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Calendar',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _navAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _navAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    
    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _goToBoard(Board board) {
    _fabAnimationController.forward();
    setState(() {
      _selectedBoard = board;
      _selectedTodo = null;
    });
  }

  void _goToTask(Todo todo) {
    _fabAnimationController.forward();
    setState(() {
      _selectedTodo = todo;
    });
  }

  void _goToToday() {
    if (_selectedBoard == null && _selectedTodo == null) {
      setState(() {
        _currentIndex = 1; // Today tab index
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goBack() {
    _fabAnimationController.reverse();
    setState(() {
      if (_selectedTodo != null) {
        _selectedTodo = null;
      } else if (_selectedBoard != null) {
        _selectedBoard = null;
      }
    });
  }

  void _onNavItemTapped(int index) {
    if (_selectedBoard == null && _selectedTodo == null && _currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Widget _getCurrentScreen() {
    if (_selectedTodo != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        child: TaskDetailScreen(
          key: ValueKey(_selectedTodo!.id),
          todo: _selectedTodo!,
          onSave: (updated) {
            context.read<TodoProvider>().updateTodo(updated);
            _goBack();
          },
          onBack: _goBack,
        ),
      );
    }

    if (_selectedBoard != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        child: TaskListScreen(
          key: ValueKey(_selectedBoard!.id),
          board: _selectedBoard!,
          onBack: _goBack,
          onTaskTap: _goToTask,
        ),
      );
    }

    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        HomeScreenWrapper(onBoardTap: _goToBoard, onTodayTap: _goToToday),
        TodayScreen(onTaskTap: _goToTask),
        CalendarScreen(onTaskTap: _goToTask),
        const AnalyticsScreen(),
        const SettingsScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showBottomNav = _selectedBoard == null && _selectedTodo == null;

    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: AnimatedBuilder(
        animation: _navAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, showBottomNav ? 0 : 100),
            child: showBottomNav ? _buildBottomNavigation() : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
            Theme.of(context).colorScheme.surface,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onNavItemTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.15),
                          Theme.of(context).colorScheme.primary.withOpacity(0.05),
                        ],
                      ) : null,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ) : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected 
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Wrapper to pass the today navigation callback
class HomeScreenWrapper extends StatelessWidget {
  final void Function(Board) onBoardTap;
  final VoidCallback onTodayTap;

  const HomeScreenWrapper({
    required this.onBoardTap,
    required this.onTodayTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeScreenWithToday(
      onBoardTap: onBoardTap,
      onTodayTap: onTodayTap,
    );
  }
}

// Updated HomeScreen to accept today navigation
class HomeScreenWithToday extends StatefulWidget {
  final void Function(Board) onBoardTap;
  final VoidCallback onTodayTap;

  const HomeScreenWithToday({
    required this.onBoardTap,
    required this.onTodayTap,
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreenWithToday> createState() => _HomeScreenWithTodayState();
}

class _HomeScreenWithTodayState extends State<HomeScreenWithToday> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _boardsAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _boardsAnimation;
  late Animation<double> _fabAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _boardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutCubic),
    );
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut),
    );
    _boardsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _boardsAnimationController, curve: Curves.elasticOut),
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _boardsAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _boardsAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  String _getGenericName() {
    final names = ['Explorer', 'Achiever', 'Champion', 'Creator', 'Innovator', 'Builder'];
    final hour = DateTime.now().hour;
    return names[hour % names.length];
  }

  String _getPersonalizedGreeting() {
    final hour = DateTime.now().hour;
    final name = _getGenericName();
    
    if (hour < 12) {
      return 'Good morning, $name!';
    } else if (hour < 17) {
      return 'Good afternoon, $name!';
    } else {
      return 'Good evening, $name!';
    }
  }

  String _getMotivationalMessage(int totalTasks, int completedTasks) {
    if (totalTasks == 0) {
      return "Ready to start your productive day?";
    } else if (completedTasks == totalTasks) {
      return "Amazing! You've completed all your tasks!";
    } else if (completedTasks > totalTasks * 0.7) {
      return "You're doing great! Almost there!";
    } else if (completedTasks > 0) {
      return "Keep up the momentum! You've got this!";
    } else {
      return "Let's make today productive!";
    }
  }

  void _showAddBoardDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColorValue = const Color(0xFF6C63FF).value;
    String selectedIconName = 'dashboard';

    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF4ECDC4),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFFF8A80),
      const Color(0xFF9C88FF),
      const Color(0xFF2ECC71),
    ];

    final icons = [
      {'name': 'dashboard', 'icon': Icons.dashboard, 'label': 'General'},
      {'name': 'work', 'icon': Icons.work, 'label': 'Work'},
      {'name': 'shopping', 'icon': Icons.shopping_cart, 'label': 'Shopping'},
      {'name': 'fitness', 'icon': Icons.fitness_center, 'label': 'Fitness'},
      {'name': 'travel', 'icon': Icons.flight, 'label': 'Travel'},
      {'name': 'home', 'icon': Icons.home, 'label': 'Home'},
      {'name': 'study', 'icon': Icons.school, 'label': 'Study'},
      {'name': 'health', 'icon': Icons.favorite, 'label': 'Health'},
    ];

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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create New Board',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Board Name',
                    hintText: 'e.g. Work Projects, Personal Goals...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    prefixIcon: const Icon(Icons.edit),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                Text(
                  'Choose Theme Color',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: colors.map((color) {
                    final isSelected = selectedColorValue == color.value;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColorValue = color.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(isSelected ? 0.5 : 0.2),
                              blurRadius: isSelected ? 12 : 6,
                              offset: Offset(0, isSelected ? 6.0 : 3.0),
                            ),
                          ],
                        ),
                        child: isSelected 
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select Icon Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: icons.length,
                    itemBuilder: (context, index) {
                      final iconData = icons[index];
                      final isSelected = selectedIconName == iconData['name'];
                      return GestureDetector(
                        onTap: () => setState(() => selectedIconName = iconData['name'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Color(selectedColorValue).withOpacity(0.1)
                                : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? Color(selectedColorValue)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                iconData['icon'] as IconData,
                                color: isSelected 
                                    ? Color(selectedColorValue)
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                iconData['label'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected 
                                      ? Color(selectedColorValue)
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.warning, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Please enter a board name'),
                              ],
                            ),
                            backgroundColor: Theme.of(context).colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      context.read<TodoProvider>().addBoard(
                        nameController.text.trim(),
                        selectedColorValue,
                        selectedIconName,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('Board "${nameController.text.trim()}" created!'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(selectedColorValue),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Create Board',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final boards = provider.boards;
        final totalTasks = provider.todos.length;
        final completedTasks = provider.todos.where((t) => t.isCompleted).length;
        final todayTasks = provider.todayTasks.length;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPersonalizedGreeting(),
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getMotivationalMessage(totalTasks, completedTasks),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
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
                          Icons.wb_sunny,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Today's Summary Card - Clickable
                if (boards.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GestureDetector(
                      onTap: widget.onTodayTap,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
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
                              ),
                              child: Icon(
                                Icons.today,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Today\'s Focus',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (todayTasks > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$todayTasks',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    todayTasks > 0
                                        ? '$todayTasks tasks due today'
                                        : 'No tasks due today',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Boards Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Text(
                        'My Boards',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (boards.isNotEmpty)
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
                          ),
                          child: Text(
                            '${boards.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Boards List
                Expanded(
                  child: boards.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: boards.length,
                          itemBuilder: (context, index) {
                            final board = boards[index];
                            final taskCount = provider.getTodosForBoard(board.id).length;
                            final completedCount = provider.getTodosForBoard(board.id).where((t) => t.isCompleted).length;
                            final progress = taskCount > 0 ? completedCount / taskCount : 0.0;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () => widget.onBoardTap(board),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(board.colorValue).withOpacity(0.1),
                                        Color(board.colorValue).withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Color(board.colorValue).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(board.colorValue),
                                                    Color(board.colorValue).withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Icon(
                                                _getIconData(board.iconName),
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    board.name,
                                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '$completedCount of $taskCount tasks completed',
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 48,
                                                  height: 48,
                                                  child: CircularProgressIndicator(
                                                    value: progress,
                                                    strokeWidth: 4,
                                                    backgroundColor: Color(board.colorValue).withOpacity(0.2),
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Color(board.colorValue),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${(progress * 100).round()}%',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(board.colorValue),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 8,
                                            backgroundColor: Color(board.colorValue).withOpacity(0.2),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Color(board.colorValue),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: AnimatedBuilder(
            animation: _fabAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () => _showAddBoardDialog(context),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.dashboard_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Welcome to Your Workspace!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Create your first board to start organizing your tasks and boost your productivity!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
      case 'study': return Icons.school;
      case 'health': return Icons.favorite;
      default: return Icons.dashboard;
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}