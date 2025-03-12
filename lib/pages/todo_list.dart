import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../services/db_service.dart';
import '../widgets/ad_wrapper.dart';
import '../main.dart';
import '../l10n/generated/l10n.dart';
import '../services/gamification_service.dart';
import 'user_stats_page.dart';

enum TaskPriority { low, medium, high }

class Task {
  int? hiveKey; // Hive-Key zum Updaten/Löschen
  final String id;
  String title;
  bool completed;
  DateTime deadline;
  DateTime createdAt;
  TaskPriority priority;
  List<String> tags;
  String? notes;

  String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
    }
  }

  Task({
    this.hiveKey,
    required this.id,
    required this.title,
    this.completed = false,
    required this.deadline,
    required this.createdAt,
    this.priority = TaskPriority.medium,
    this.tags = const ['General'],
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'priority': _priorityToString(priority),
      'tags': tags,
      'notes': notes,
    };
  }
}

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({Key? key}) : super(key: key);

  @override
  _ToDoListPageState createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage>
    with SingleTickerProviderStateMixin {
  final _uuid = const Uuid();
  final DBService _dbService = DBService();
  bool _hideCompleted = false;
  TaskPriority? _filterPriority;
  String? _filterTag;
  bool _notificationsOn = false;
  DateTime _newTaskDeadline = DateTime.now();
  TaskPriority _newTaskPriority = TaskPriority.medium;
  List<String> _newTaskTags = ['General'];
  String? _newTaskNotes;
  final List<String> _defaultTags = [
    'General',
    'Work',
    'Private',
    'Sport',
    'Health',
    'Finance'
  ];

  // UI control
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Initialize Timezone data
    _tabController = TabController(length: 3, vsync: this);

    // Check notification status
    _checkNotificationStatus();

    // Load user preferences
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkNotificationStatus() async {
    final prefs = Hive.box('settings');
    setState(() {
      _notificationsOn = prefs.get('notificationsOn', defaultValue: false);
    });
  }

  Future<void> _loadUserPreferences() async {
    final prefs = Hive.box('settings');
    setState(() {
      _hideCompleted = prefs.get('hideCompleted', defaultValue: false);
    });
  }

  Future<void> _toggleNotifications() async {
    setState(() => _notificationsOn = !_notificationsOn);
    final prefs = Hive.box('settings');
    await prefs.put('notificationsOn', _notificationsOn);

    if (_notificationsOn) {
      await scheduleDailyTodoReminder();
      _showSnackBar(S.of(context).dailyReminderActivated);
    } else {
      const notificationId = 5678;
      await fln.FlutterLocalNotificationsPlugin().cancel(notificationId);
      _showSnackBar(S.of(context).dailyReminderDeactivated);
    }
  }

  // Verbessert die Lesbarkeit der Notifications
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.black87,
        action: SnackBarAction(
          label: 'OK',
          textColor: const Color(0xFFDF1B1B),
          onPressed: () {},
        ),
      ),
    );
  }

  // Neuer Helper zum Parsen von Datum: Akzeptiert sowohl int als auch String
  DateTime _parseDate(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.parse(value);
    } else {
      return DateTime.now(); // Fallback, sollte nicht passieren
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return AdWrapper(
      child: Scaffold(
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              if (notification.scrollDelta != null && notification.scrollDelta! > 0) {
                if (_showFab) setState(() => _showFab = false);
              } else {
                if (!_showFab) setState(() => _showFab = true);
              }
            }
            return true;
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.grey.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, loc),
                  if (_isSearching) _buildSearchBar(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTasksList(context, 'all'),
                        _buildTasksList(context, 'today'),
                        _buildTasksList(context, 'upcoming'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: _showFab ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showFab ? 1.0 : 0.0,
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFFDF1B1B),
              onPressed: _showAddTaskSheet,
              icon: const Icon(Icons.add),
              label: Text(loc.addTask),
              elevation: 4,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, S loc) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              loc.todoListTitle,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              _notificationsOn ? Icons.notifications_active : Icons.notifications_off,
              color: _notificationsOn ? const Color(0xFFDF1B1B) : Colors.white,
            ),
            onPressed: _toggleNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserStatsPage()),
              ).then((_) => setState(() {}));
            },
          ),
          _buildFilterButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          ),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  // Angepasst: Vollflächiger Tab-Indicator dank indicatorSize.tab
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFFDF1B1B),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Today'),
          Tab(text: 'Upcoming'),
        ],
        onTap: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Badge(
        isLabelVisible: _filterPriority != null || _filterTag != null || _hideCompleted,
        backgroundColor: const Color(0xFFDF1B1B),
        child: const Icon(Icons.filter_list, color: Colors.white),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[850],
      onSelected: (value) {
        if (value == 'clear') {
          setState(() {
            _hideCompleted = false;
            _filterPriority = null;
            _filterTag = null;
          });
        } else if (value == 'hideDone') {
          setState(() => _hideCompleted = !_hideCompleted);
          final prefs = Hive.box('settings');
          prefs.put('hideCompleted', _hideCompleted);
        } else if (value.startsWith('priority_')) {
          final prio = value.split('_')[1];
          setState(() => _filterPriority = _stringToPriority(prio));
        } else if (value.startsWith('tag_')) {
          final tag = value.split('_')[1];
          setState(() => _filterTag = tag);
        }
      },
      itemBuilder: (context) {
        final tasks = _boxToTaskList(_dbService.listenableTasks().value);
        final uniqueTags = tasks.expand((t) => t.tags).toSet().toList();

        return [
          PopupMenuItem(
            value: 'clear',
            child: Row(
              children: [
                Icon(
                  Icons.clear_all,
                  color: Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text('Clear filters', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'hideDone',
            child: Row(
              children: [
                Icon(
                  _hideCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                  color: _hideCompleted ? const Color(0xFFDF1B1B) : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _hideCompleted ? 'Show completed' : 'Hide completed',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            enabled: false,
            height: 28,
            child: Text(
              'Priority',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
          ...TaskPriority.values.map((p) => PopupMenuItem(
                value: 'priority_${_priorityToString(p)}',
                child: Row(
                  children: [
                    Icon(
                      _getPriorityIcon(p),
                      color: _filterPriority == p ? _getPriorityColor(p) : Colors.grey[400],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getPriorityText(p),
                      style: TextStyle(
                        color: _filterPriority == p ? _getPriorityColor(p) : Colors.white,
                      ),
                    ),
                  ],
                ),
              )),
          if (uniqueTags.isNotEmpty) ...[
            const PopupMenuDivider(),
            PopupMenuItem(
              enabled: false,
              height: 28,
              child: Text(
                'Tags',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
            ...uniqueTags.map((tag) => PopupMenuItem(
                  value: 'tag_$tag',
                  child: Row(
                    children: [
                      Icon(
                        Icons.label,
                        color: _filterTag == tag ? const Color(0xFFDF1B1B) : Colors.grey[400],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        tag,
                        style: TextStyle(
                          color: _filterTag == tag ? const Color(0xFFDF1B1B) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ];
      },
    );
  }

  Widget _buildTasksList(BuildContext context, String type) {
    final loc = S.of(context);
    return ValueListenableBuilder(
      valueListenable: _dbService.listenableTasks(),
      builder: (context, Box box, child) {
        if (box.isEmpty) {
          return _buildEmptyState(loc.noTasks);
        }

        final allTasks = _boxToTaskList(box);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Filter by tab type
        var filteredTasks = allTasks.where((task) {
          final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);

          if (type == 'today') {
            return taskDate.isAtSameMomentAs(today);
          } else if (type == 'upcoming') {
            return taskDate.isAfter(today);
          }
          return true;
        }).toList();

        // Apply custom filters and search
        filteredTasks = filteredTasks.where((t) {
          if (_hideCompleted && t.completed) return false;
          if (_filterPriority != null && t.priority != _filterPriority) return false;
          if (_filterTag != null && !t.tags.contains(_filterTag)) return false;
          if (_searchQuery.isNotEmpty &&
              !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return false;
          }
          return true;
        }).toList();

        if (filteredTasks.isEmpty) {
          return _buildEmptyState(loc.noMatchingTasks);
        }

        // Group and sort tasks
        filteredTasks.sort((a, b) {
          // Sort by deadline first
          final dateComp = a.deadline.compareTo(b.deadline);
          if (dateComp != 0) return dateComp;

          // Then by priority (high to low)
          final prioComp = b.priority.index.compareTo(a.priority.index);
          if (prioComp != 0) return prioComp;

          // Then by creation time (newest first)
          return b.createdAt.compareTo(a.createdAt);
        });

        final grouped = _groupTasksByDate(filteredTasks);
        final sortedDates = grouped.keys.toList()..sort();

        return ListView.builder(
          itemCount: sortedDates.length,
          padding: const EdgeInsets.only(bottom: 80, top: 8),
          itemBuilder: (context, index) {
            final dateKey = sortedDates[index];
            var tasksForDate = grouped[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateHeader(dateKey, tasksForDate),
                ...tasksForDate.map((task) => _buildTaskCard(task)),
              ],
            ).animate().fadeIn(duration: 200.ms, delay: (50 * index).ms);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddTaskSheet,
            icon: const Icon(Icons.add),
            label: const Text("Add a task"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDF1B1B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildDateHeader(DateTime date, List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    final dateOnly = DateTime(date.year, date.month, date.day);
    String dateText;

    if (dateOnly.isAtSameMomentAs(today)) {
      dateText = 'Today';
    } else if (dateOnly.isAtSameMomentAs(tomorrow)) {
      dateText = 'Tomorrow';
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('EEEE, MMM d').format(date);
    }

    final overdueText = dateOnly.isBefore(today) && tasks.any((t) => !t.completed)
        ? ' (Overdue)'
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: dateOnly.isAtSameMomentAs(today)
                  ? const Color(0xFFDF1B1B).withOpacity(0.2)
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dateText + overdueText,
              style: TextStyle(
                color: dateOnly.isAtSameMomentAs(today)
                    ? const Color(0xFFDF1B1B)
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: Colors.grey[700],
              thickness: 1,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${tasks.length} tasks',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final loc = S.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
    final isOverdue = taskDate.isBefore(today) && !task.completed;

    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            backgroundColor: const Color(0xFFDF1B1B),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            onPressed: (_) => _deleteTask(task),
          ),
        ],
      ),
      child: Card(
        color: Colors.grey[850],
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isOverdue
                ? const Color(0xFFDF1B1B).withOpacity(0.5)
                : Colors.transparent,
            width: isOverdue ? 1 : 0,
          ),
        ),
        elevation: 2,
        child: InkWell(
          onTap: () => _editTask(task),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    onTap: () => _toggleTask(task),
                    customBorder: const CircleBorder(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.completed ? _getPriorityColor(task.priority) : Colors.transparent,
                        border: Border.all(
                          color: _getPriorityColor(task.priority),
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: task.completed
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : const SizedBox(width: 16, height: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.notes != null && task.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            task.notes!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              decoration: task.completed ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: isOverdue ? const Color(0xFFDF1B1B) : Colors.grey[400],
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.deadline),
                            style: TextStyle(
                              color: isOverdue ? const Color(0xFFDF1B1B) : Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            _getPriorityIcon(task.priority),
                            color: _getPriorityColor(task.priority),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPriorityText(task.priority),
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (task.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: task.tags.map((tag) => _buildTagChip(tag)).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 12,
        ),
      ),
    );
  }

  void _showAddTaskSheet() {
    final loc = S.of(context);
    final TextEditingController titleController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    _newTaskDeadline = DateTime.now();
    _newTaskPriority = TaskPriority.medium;
    _newTaskTags = ['General'];
    _newTaskNotes = null;

    final bool isPremium = Hive.box('settings').get('isPremium', defaultValue: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(ctx).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.newTaskHint,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: loc.taskTitleLabel,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFDF1B1B)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: notesController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: loc.taskNotesLabel,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFDF1B1B)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _newTaskNotes = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text(
                            'Deadline: ${_formatDate(_newTaskDeadline)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _newTaskDeadline,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFFDF1B1B),
                                        onSurface: Colors.white,
                                      ),
                                      dialogBackgroundColor: Colors.grey[900],
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  _newTaskDeadline = picked;
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFDF1B1B),
                            ),
                            child: Text(loc.changeDate),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Priority:',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: TaskPriority.values.map((p) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _newTaskPriority = p;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _newTaskPriority == p
                                    ? _getPriorityColor(p).withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _newTaskPriority == p
                                      ? _getPriorityColor(p)
                                      : Colors.grey[700]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getPriorityIcon(p),
                                    color: _newTaskPriority == p
                                        ? _getPriorityColor(p)
                                        : Colors.grey[400],
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getPriorityText(p),
                                    style: TextStyle(
                                      color: _newTaskPriority == p
                                          ? _getPriorityColor(p)
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tags:',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _defaultTags.map((tag) {
                          final selected = _newTaskTags.contains(tag);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  if (_newTaskTags.length > 1) {
                                    _newTaskTags.remove(tag);
                                  }
                                } else {
                                  _newTaskTags.add(tag);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFFDF1B1B).withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected ? const Color(0xFFDF1B1B) : Colors.grey[700]!,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: selected ? const Color(0xFFDF1B1B) : Colors.white,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDF1B1B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (titleController.text.trim().isNotEmpty) {
                              _addTask(titleController.text.trim(), notesController.text);
                              Navigator.pop(ctx);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loc.emptyTitleError, style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text(loc.addTask),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addTask(String title, String? notes) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      deadline: _newTaskDeadline,
      createdAt: DateTime.now(),
      priority: _newTaskPriority,
      tags: _newTaskTags,
      notes: notes?.isNotEmpty == true ? notes : null,
    );

    // Übergib ein Map statt einem Task-Objekt
    await _dbService.addTask(task.toMap());

    final gamification = GamificationService();
    gamification.addXP(10);
    _showSnackBar(S.of(context).taskAdded);
  }

  void _toggleTask(Task task) async {
    final updatedTask = Task(
      hiveKey: task.hiveKey,
      id: task.id,
      title: task.title,
      completed: !task.completed,
      deadline: task.deadline,
      createdAt: task.createdAt,
      priority: task.priority,
      tags: task.tags,
      notes: task.notes,
    );

    await _dbService.updateTask(task.hiveKey!, updatedTask.toMap());

    if (updatedTask.completed) {
      final gamification = GamificationService();
      int points = task.priority == TaskPriority.high
          ? 30
          : task.priority == TaskPriority.medium
              ? 20
              : 10;
      gamification.addXP(points);
      _showSnackBar(S.of(context).taskCompletedMessage);
      HapticFeedback.mediumImpact();
    }
  }

  void _editTask(Task task) {
    final TextEditingController titleController =
        TextEditingController(text: task.title);
    final TextEditingController notesController =
        TextEditingController(text: task.notes ?? '');

    DateTime editTaskDeadline = task.deadline;
    TaskPriority editTaskPriority = task.priority;
    List<String> editTaskTags = List.from(task.tags);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: MediaQuery.of(ctx).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hier sollten ähnliche Formularfelder wie in _showAddTaskSheet
                      // mit vorausgefüllten Werten stehen
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDF1B1B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (titleController.text.trim().isNotEmpty) {
                              _updateTask(
                                task,
                                titleController.text.trim(),
                                notesController.text,
                                editTaskDeadline,
                                editTaskPriority,
                                editTaskTags,
                              );
                              Navigator.pop(ctx);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(S.of(context).emptyTitleError, style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text(S.of(context).updateTask),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateTask(
    Task task,
    String title,
    String? notes,
    DateTime deadline,
    TaskPriority priority,
    List<String> tags,
  ) async {
    final updatedTask = Task(
      hiveKey: task.hiveKey,
      id: task.id,
      title: title,
      completed: task.completed,
      deadline: deadline,
      createdAt: task.createdAt,
      priority: priority,
      tags: tags,
      notes: notes?.isNotEmpty == true ? notes : null,
    );

    await _dbService.updateTask(task.hiveKey!, updatedTask.toMap());
    _showSnackBar(S.of(context).taskUpdatedMessage);
  }

  Future<void> _deleteTask(Task task) async {
    await _dbService.deleteTask(task.hiveKey!);
    _showSnackBar(S.of(context).taskDeleted);
  }

  Future<void> scheduleDailyTodoReminder() async {
    const notificationId = 5678;
    final time = const TimeOfDay(hour: 9, minute: 0);

    final flutterLocalNotificationsPlugin =
        fln.FlutterLocalNotificationsPlugin();

    // Erstelle eine zeitbasierte Notification
    final scheduledDate = _nextInstanceOfTime(time);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      S.of(context).todoReminderTitleHard,
      S.of(context).todoReminderBodyHard,
      scheduledDate,
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'todo_reminders',
          'Todo Reminders',
          channelDescription: 'Daily reminders for todo tasks',
          importance: fln.Importance.high,
          priority: fln.Priority.high,
          color: Color(0xFFDF1B1B),
        ),
        iOS: fln.DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: fln.DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Helper methods
  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final grouped = <DateTime, List<Task>>{};

    for (final task in tasks) {
      final dateKey = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }

      grouped[dateKey]!.add(task);
    }

    return grouped;
  }

  List<Task> _boxToTaskList(Box box) {
    return box.toMap().entries.map((entry) {
      final key = entry.key;
      final map = Map<String, dynamic>.from(entry.value);
      return Task(
        hiveKey: key,
        id: map['id'],
        title: map['title'],
        completed: map['completed'] ?? false,
        deadline: _parseDate(map['deadline']),
        createdAt: _parseDate(map['createdAt']),
        priority: _stringToPriority(map['priority'] ?? 'medium'),
        tags: List<String>.from(map['tags'] ?? ['General']),
        notes: map['notes'],
      );
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dateOnly.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  // Fix: _stringToPriority akzeptiert jetzt sowohl int als auch String
  TaskPriority _stringToPriority(dynamic priority) {
    if (priority is int) {
      switch (priority) {
        case 0:
          return TaskPriority.low;
        case 1:
          return TaskPriority.medium;
        case 2:
          return TaskPriority.high;
        default:
          return TaskPriority.medium;
      }
    } else if (priority is String) {
      switch (priority.toLowerCase()) {
        case 'high':
          return TaskPriority.high;
        case 'low':
          return TaskPriority.low;
        case 'medium':
        default:
          return TaskPriority.medium;
      }
    }
    return TaskPriority.medium;
  }

  String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'high';
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
      default:
        return 'medium';
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.low:
        return Icons.arrow_downward;
      case TaskPriority.medium:
      default:
        return Icons.drag_handle;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFDF1B1B);
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
      default:
        return Colors.orange;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
      default:
        return 'Medium';
    }
  }
}
