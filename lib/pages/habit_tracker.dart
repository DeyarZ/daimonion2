// lib/pages/habit_tracker.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// Services
import '../services/db_service.dart';
import '../services/gamification_service.dart';

// Notification-Funktionen
import 'package:daimonion_app/main.dart'
    show scheduleHabitNotifications, cancelHabitNotifications;

// Lokalisierung
import '../l10n/generated/l10n.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Model-Klasse: Habit
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class Habit {
  String id;
  String name;
  Map<String, bool?> dailyStatus;
  List<int> selectedWeekdays;
  int? reminderHour;
  int? reminderMinute;
  String? category; // New: Allow categorization of habits
  Color? color; // New: Custom color per habit
  
  Habit({
    required this.id,
    required this.name,
    required this.dailyStatus,
    required this.selectedWeekdays,
    this.reminderHour,
    this.reminderMinute,
    this.category,
    this.color,
  });
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Haupt-Klasse: HabitTrackerPage
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({Key? key}) : super(key: key);

  @override
  _HabitTrackerPageState createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> with SingleTickerProviderStateMixin {
  final DBService _dbService = DBService();
  final _uuid = const Uuid();
  
  late DateTime today;
  late List<DateTime> days; // -3 .. +3
  late TabController _tabController;
  
  // Predefined categories and colors
  final List<String> categories = ['Health', 'Productivity', 'Learning', 'Personal'];
  final List<Color> predefinedColors = [
    const Color(0xFF1E88E5), // Blue
    const Color(0xFF43A047), // Green
    const Color(0xFFE53935), // Red
    const Color(0xFF8E24AA), // Purple
    const Color(0xFFEF6C00), // Orange
    const Color(0xFF00ACC1), // Cyan
  ];
  
  // Animation controllers
  bool _showCompletedHabits = true;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  @override
  void initState() {
    super.initState();
    today = _truncateToDate(DateTime.now());
    days = _generate7Days(today);
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // BUILD
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade900,
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 100), // Runterziehen des Titels
                  title: Text(
                    loc.habitTrackerTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade900.withOpacity(0.7), 
                          Colors.black.withOpacity(0.9)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _showCompletedHabits ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _showCompletedHabits = !_showCompletedHabits;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.white70,
                    ),
                    onPressed: () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: today,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: Theme.of(context).primaryColor,
                                onPrimary: Colors.white,
                                surface: Colors.grey.shade900,
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (selectedDate != null) {
                        setState(() {
                          today = selectedDate;
                          days = _generate7Days(today);
                        });
                      }
                    },
                  ),
                ],
            bottom: PreferredSize(
  // Höhe erhöhen, damit die Spalte Platz hat.
  preferredSize: const Size.fromHeight(70),
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${loc.todayLabel}: ${_formatDate(today)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color.fromARGB(255, 223, 27, 27),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: const Color.fromARGB(255, 223, 27, 27),
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: loc.allHabits),
            Tab(text: loc.byCategory),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Content
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllHabitsTab(context),
                      _buildCategoriesTab(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: _addHabit,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // ALL HABITS TAB
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildAllHabitsTab(BuildContext context) {
    final loc = S.of(context);
    
    return ValueListenableBuilder(
      valueListenable: _dbService.listenableHabits(),
      builder: (context, Box box, _) {
        List<Habit> habits = _boxToHabitList(box);
        
        // Filter out completed habits if the toggle is off
        if (!_showCompletedHabits) {
          habits = habits.where((habit) {
            final todayKey = _formatDateKey(today);
            return habit.dailyStatus[todayKey] != true;
          }).toList();
        }
        
        if (habits.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.track_changes_outlined,
                  size: 80,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.noHabitsMessage,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(loc.addNewHabit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _addHabit,
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return _buildHabitItem(habit);
          },
        );
      },
    );
  }
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // CATEGORIES TAB
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildCategoriesTab(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _dbService.listenableHabits(),
      builder: (context, Box box, _) {
        final habits = _boxToHabitList(box);
        final Map<String, List<Habit>> categorizedHabits = {};
        
        // Initialize with default categories
        for (String category in categories) {
          categorizedHabits[category] = [];
        }
        
        // Add an "Uncategorized" category
        categorizedHabits['Uncategorized'] = [];
        
        // Organize habits by category
        for (var habit in habits) {
          final category = habit.category ?? 'Uncategorized';
          if (categorizedHabits.containsKey(category)) {
            categorizedHabits[category]!.add(habit);
          } else {
            categorizedHabits[category] = [habit];
          }
        }
        
        // Filter out empty categories
        final nonEmptyCategories = categorizedHabits.entries
            .where((entry) => entry.value.isNotEmpty)
            .toList();
        
        if (nonEmptyCategories.isEmpty) {
          return Center(
            child: Text(
              S.of(context).noHabitsMessage,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: nonEmptyCategories.length,
          itemBuilder: (context, categoryIndex) {
            final category = nonEmptyCategories[categoryIndex].key;
            final categoryHabits = nonEmptyCategories[categoryIndex].value;
            
            return ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              collapsedIconColor: Colors.white70,
              iconColor: Colors.white,
              children: categoryHabits.map((habit) => _buildHabitItem(habit)).toList(),
            );
          },
        );
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 1) HABIT ITEM
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildHabitItem(Habit habit) {
    final habitColor = habit.color ?? Theme.of(context).primaryColor;
    final bool isForToday = habit.selectedWeekdays.contains(today.weekday);
    final String dayKey = _formatDateKey(today);
    final bool? currentStatus = habit.dailyStatus[dayKey];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                _showEditHabitDialog(habit);
              },
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: S.of(context).edit,
            ),
            SlidableAction(
              onPressed: (_) async {
                final shouldDelete = await _confirmDeleteHabit(habit);
                if (shouldDelete) {
                  await _deleteHabit(habit);
                }
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: S.of(context).delete,
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          color: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: habitColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header with name and status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey.shade900,
                ),
                child: Row(
                  children: [
                    // Icon or indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: habitColor.withOpacity(0.2),
                        border: Border.all(
                          color: habitColor,
                          width: 2,
                        ),
                      ),
                      child: isForToday && currentStatus == true
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: habitColor,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    
                    // Name
                    Expanded(
                      child: Text(
                        habit.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Reminder indicator
                    if (habit.reminderHour != null && habit.reminderMinute != null)
                      Tooltip(
                        message: '${_formatTimeFromHourMinute(habit.reminderHour!, habit.reminderMinute!)}',
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Calendar row
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _buildCalendarRow(habit),
              ),
              
              // Action buttons 
              if (isForToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    color: Colors.black26,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCategoryText(habit),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          _buildStatusButton(
                            habit: habit,
                            dayKey: dayKey,
                            icon: Icons.check,
                            color: Colors.green,
                            status: true,
                            isSelected: currentStatus == true,
                          ),
                          const SizedBox(width: 8),
                          _buildStatusButton(
                            habit: habit,
                            dayKey: dayKey,
                            icon: Icons.close,
                            color: Colors.red,
                            status: false,
                            isSelected: currentStatus == false,
                          ),
                          const SizedBox(width: 8),
                          _buildStatusButton(
                            habit: habit,
                            dayKey: dayKey,
                            icon: Icons.remove,
                            color: Colors.grey,
                            status: null,
                            isSelected: currentStatus == null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getCategoryText(Habit habit) {
    return habit.category != null ? habit.category! : S.of(context).uncategorized;
  }
  
  Widget _buildStatusButton({
    required Habit habit,
    required String dayKey,
    required IconData icon,
    required Color color,
    required bool? status,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => _toggleHabitStatus(habit, dayKey, newVal: status),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? color : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.white30,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white30,
          size: 16,
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 2) CALENDAR ROW
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildCalendarRow(Habit habit) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((day) {
          final dayKey = _formatDateKey(day);
          final isSelectedDay = habit.selectedWeekdays.contains(day.weekday);
          final status = habit.dailyStatus[dayKey];
          final isToday = _isSameDay(day, today);
          
          Color circleColor;
          IconData? icon;
          
          if (!isSelectedDay) {
            // Gray for days where habit is not scheduled
            circleColor = Colors.grey.shade700.withOpacity(0.3);
            icon = null;
          } else if (status == true) {
            // Completed
            circleColor = Colors.green;
            icon = Icons.check;
          } else if (status == false) {
            // Skipped
            circleColor = Colors.red;
            icon = Icons.close;
          } else {
            // Not marked yet
            circleColor = isToday ? Colors.amber.withOpacity(0.3) : Colors.grey.shade600.withOpacity(0.3);
            icon = null;
          }
          
          return GestureDetector(
            onTap: isSelectedDay ? () => _toggleHabitStatus(habit, dayKey) : null,
            child: Container(
              width: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  // Day of week
                  Text(
                    _dayOfWeekLetter(day.weekday),
                    style: TextStyle(
                      color: isToday ? Colors.amber : Colors.white70,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Circle indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circleColor,
                      border: isToday
                          ? Border.all(color: Colors.amber, width: 2)
                          : null,
                    ),
                    child: icon != null
                        ? Icon(icon, color: Colors.white, size: 20)
                        : Center(
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(
                                color: isToday ? Colors.amber : Colors.white70,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 3) ADD HABIT
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _addHabit() {
    final nameController = TextEditingController();
    final selectedDays = <int>{};
    final selectedCategory = ValueNotifier<String?>(null);
    final selectedColor = ValueNotifier<Color>(predefinedColors.first);
    int? chosenHour;
    int? chosenMinute;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle and title
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Title
                        Text(
                          S.of(ctx).newHabitTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          TextField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: S.of(ctx).habitNameLabel,
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.grey.shade800,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.edit,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Weekdays selection
                          Text(
                            S.of(ctx).repeatLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(7, (i) {
                                final weekday = i + 1; // Mo=1,...,So=7
                                final label = _dayOfWeekLetter(weekday);
                                final isSelected = selectedDays.contains(weekday);
                                
                                return GestureDetector(
                                  onTap: () {
                                    setStateModal(() {
                                      if (isSelected) {
                                        selectedDays.remove(weekday);
                                      } else {
                                        selectedDays.add(weekday);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade700,
                                    ),
                                    child: Center(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white70,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Category dropdown
                          Text(
                            S.of(ctx).categoryLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          ValueListenableBuilder<String?>(
                            valueListenable: selectedCategory,
                            builder: (ctx, value, _) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: value,
                                    isExpanded: true,
                                    dropdownColor: Colors.grey.shade800,
                                    style: const TextStyle(color: Colors.white),
                                    hint: Text(
                                      S.of(ctx).selectCategory,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white70,
                                    ),
                                    items: [
                                      ...categories.map((category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      )),
                                    ],
                                    onChanged: (newValue) {
                                      selectedCategory.value = newValue;
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Color selection
                          Text(
                            S.of(ctx).colorLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          ValueListenableBuilder<Color>(
                            valueListenable: selectedColor,
                            builder: (ctx, value, _) {
                              return Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: predefinedColors.length,
                                  itemBuilder: (ctx, index) {
                                    final color = predefinedColors[index];
                                    final isSelected = color == value;
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        selectedColor.value = color;
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                          border: isSelected
                                              ? Border.all(color: Colors.white, width: 2)
                                              : null,
                                        ),
                                        child: isSelected
                                            ? const Center(
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Reminder
                          Text(
                            S.of(ctx).reminderLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chosenHour != null 
                                        ? _formatTimeFromHourMinute(chosenHour!, chosenMinute ?? 0) 
                                        : S.of(ctx).noReminderSet,
                                    style: TextStyle(
                                      color: chosenHour != null ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.access_time),
                                  label: Text(S.of(ctx).setTime),
                                  onPressed: () async {
                                    final TimeOfDay? timeOfDay = await showTimePicker(
                                      context: ctx,
                                      initialTime: TimeOfDay.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.dark().copyWith(
                                            colorScheme: ColorScheme.dark(
                                              primary: Theme.of(context).primaryColor,
                                              onPrimary: Colors.white,
                                              surface: Colors.grey.shade900,
                                              onSurface: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    
                                    if (timeOfDay != null) {
                                      setStateModal(() {
                                        chosenHour = timeOfDay.hour;
                                        chosenMinute = timeOfDay.minute;
                                      });
                                    }
                                  },
                                ),
                                if (chosenHour != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setStateModal(() {
                                        chosenHour = null;
                                        chosenMinute = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              S.of(ctx).cancel,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate input
                              if (nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(ctx).emptyNameError),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              if (selectedDays.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(ctx).noDaysSelectedError),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              // Create new habit
                              _createHabit(
                                name: nameController.text.trim(),
                                weekdays: selectedDays.toList(),
                                reminderHour: chosenHour,
                                reminderMinute: chosenMinute,
                                category: selectedCategory.value,
                                color: selectedColor.value,
                              );
                              
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(S.of(ctx).save),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // 4) EDIT HABIT
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _showEditHabitDialog(Habit habit) {
    final nameController = TextEditingController(text: habit.name);
    final selectedDays = habit.selectedWeekdays.toSet();
    final selectedCategory = ValueNotifier<String?>(habit.category);
    final selectedColor = ValueNotifier<Color>(habit.color ?? predefinedColors.first);
    int? chosenHour = habit.reminderHour;
    int? chosenMinute = habit.reminderMinute;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateModal) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle and title
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Title
                        Text(
                          S.of(ctx).editHabitTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form content - Reuse the same layout as add habit
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          TextField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: S.of(ctx).habitNameLabel,
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.grey.shade800,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(
                                Icons.edit,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Weekdays selection
                          Text(
                            S.of(ctx).repeatLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(7, (i) {
                                final weekday = i + 1; // Mo=1,...,So=7
                                final label = _dayOfWeekLetter(weekday);
                                final isSelected = selectedDays.contains(weekday);
                                
                                return GestureDetector(
                                  onTap: () {
                                    setStateModal(() {
                                      if (isSelected) {
                                        selectedDays.remove(weekday);
                                      } else {
                                        selectedDays.add(weekday);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey.shade700,
                                    ),
                                    child: Center(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white70,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Category dropdown
                          Text(
                            S.of(ctx).categoryLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          ValueListenableBuilder<String?>(
                            valueListenable: selectedCategory,
                            builder: (ctx, value, _) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade800,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: value,
                                    isExpanded: true,
                                    dropdownColor: Colors.grey.shade800,
                                    style: const TextStyle(color: Colors.white),
                                    hint: Text(
                                      S.of(ctx).selectCategory,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white70,
                                    ),
                                    items: [
                                      ...categories.map((category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      )),
                                    ],
                                    onChanged: (newValue) {
                                      selectedCategory.value = newValue;
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Color selection
                          Text(
                            S.of(ctx).colorLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          ValueListenableBuilder<Color>(
                            valueListenable: selectedColor,
                            builder: (ctx, value, _) {
                              return Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: predefinedColors.length,
                                  itemBuilder: (ctx, index) {
                                    final color = predefinedColors[index];
                                    final isSelected = color == value;
                                    
                                    return GestureDetector(
                                      onTap: () {
                                        selectedColor.value = color;
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                          border: isSelected
                                              ? Border.all(color: Colors.white, width: 2)
                                              : null,
                                        ),
                                        child: isSelected
                                            ? const Center(
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Reminder
                          Text(
                            S.of(ctx).reminderLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    chosenHour != null 
                                        ? _formatTimeFromHourMinute(chosenHour!, chosenMinute ?? 0) 
                                        : S.of(ctx).noReminderSet,
                                    style: TextStyle(
                                      color: chosenHour != null ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.access_time),
                                  label: Text(S.of(ctx).setTime),
                                  onPressed: () async {
                                    final TimeOfDay? timeOfDay = await showTimePicker(
                                      context: ctx,
                                      initialTime: chosenHour != null 
                                          ? TimeOfDay(hour: chosenHour!, minute: chosenMinute ?? 0) 
                                          : TimeOfDay.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: ThemeData.dark().copyWith(
                                            colorScheme: ColorScheme.dark(
                                              primary: Theme.of(context).primaryColor,
                                              onPrimary: Colors.white,
                                              surface: Colors.grey.shade900,
                                              onSurface: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    
                                    if (timeOfDay != null) {
                                      setStateModal(() {
                                        chosenHour = timeOfDay.hour;
                                        chosenMinute = timeOfDay.minute;
                                      });
                                    }
                                  },
                                ),
                                if (chosenHour != null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () {
                                      setStateModal(() {
                                        chosenHour = null;
                                        chosenMinute = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Buttons
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              S.of(ctx).cancel,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate input
                              if (nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(ctx).emptyNameError),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              if (selectedDays.isEmpty) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(S.of(ctx).noDaysSelectedError),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              
                              // Update habit
                              _updateHabit(
                                habitId: habit.id,
                                name: nameController.text.trim(),
                                weekdays: selectedDays.toList(),
                                dailyStatus: habit.dailyStatus,
                                reminderHour: chosenHour,
                                reminderMinute: chosenMinute,
                                category: selectedCategory.value,
                                color: selectedColor.value,
                              );
                              
                              Navigator.of(ctx).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(S.of(ctx).update),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // HELPER METHODS
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  // Create a new habit
  void _createHabit({
    required String name,
    required List<int> weekdays,
    int? reminderHour,
    int? reminderMinute,
    String? category,
    required Color color,
  }) async {
    final String id = _uuid.v4();
    
    // Initialize with empty dailyStatus
    final Map<String, bool?> dailyStatus = {};
    
    // Save to database
    await _dbService.saveHabit(
      id: id,
      name: name,
      dailyStatus: dailyStatus,
      weekdays: weekdays,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      category: category,
      colorValue: color.value,
    );
    
    // Schedule notification if reminder is set
    if (reminderHour != null && reminderMinute != null) {
      scheduleHabitNotifications(
        id: id,
        title: name,
        weekdays: weekdays,
        hour: reminderHour,
        minute: reminderMinute,
      );
    }
    
    // Update gamification
    //GamificationService().addPoints(20, 'habit_created');
    
    setState(() {});
  }
  
  // Update an existing habit
  void _updateHabit({
    required String habitId,
    required String name,
    required List<int> weekdays,
    required Map<String, bool?> dailyStatus,
    int? reminderHour,
    int? reminderMinute,
    String? category,
    required Color color,
  }) async {
    // Save to database
    await _dbService.saveHabit(
      id: habitId,
      name: name,
      dailyStatus: dailyStatus,
      weekdays: weekdays,
      reminderHour: reminderHour,
      reminderMinute: reminderMinute,
      category: category,
      colorValue: color.value,
    );
    
    // Update notifications
    // First cancel existing ones
    cancelHabitNotifications(habitId);
    
    // Schedule new ones if reminder is set
    if (reminderHour != null && reminderMinute != null) {
      scheduleHabitNotifications(
        id: habitId,
        title: name,
        weekdays: weekdays,
        hour: reminderHour,
        minute: reminderMinute,
      );
    }
    
    setState(() {});
  }
  
  // Delete a habit
  Future<void> _deleteHabit(Habit habit) async {
    // Cancel any scheduled notifications
    cancelHabitNotifications(habit.id);
    
    // Delete from database
    await _dbService.deleteHabit(habit.id);
    
    // Give feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.name} ${S.of(context).habitDeleted}'),
        action: SnackBarAction(
          label: S.of(context).undo,
          onPressed: () {
            _dbService.saveHabit(
              id: habit.id,
              name: habit.name,
              dailyStatus: habit.dailyStatus,
              weekdays: habit.selectedWeekdays,
              reminderHour: habit.reminderHour,
              reminderMinute: habit.reminderMinute,
              category: habit.category,
              colorValue: habit.color?.value,
            );
            // Reschedule notifications if needed
            if (habit.reminderHour != null && habit.reminderMinute != null) {
              scheduleHabitNotifications(
                id: habit.id, 
                title: habit.name,
                weekdays: habit.selectedWeekdays,
                hour: habit.reminderHour!,
                minute: habit.reminderMinute!,
              );
            }
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
    
    setState(() {});
  }
  
  // Confirm delete dialog
  Future<bool> _confirmDeleteHabit(Habit habit) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          S.of(ctx).deleteHabitTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '${S.of(ctx).deleteHabitConfirmation} "${habit.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              S.of(ctx).cancel,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              S.of(ctx).delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
  
  // Toggle habit status
  void _toggleHabitStatus(Habit habit, String dayKey, {bool? newVal}) {
    final currentStatus = habit.dailyStatus[dayKey];
    bool? newStatus;
    
    if (newVal != null) {
      // Directly set to provided value
      newStatus = newVal;
    } else {
      // Cycle through states: null -> true -> false -> null
      if (currentStatus == null) {
        newStatus = true;
      } else if (currentStatus == true) {
        newStatus = false;
      } else {
        newStatus = null;
      }
    }
    
    // Update status
    Map<String, bool?> updatedStatus = Map.from(habit.dailyStatus);
    updatedStatus[dayKey] = newStatus;
    
    // Save to database
    _updateHabit(
      habitId: habit.id,
      name: habit.name,
      weekdays: habit.selectedWeekdays,
      dailyStatus: updatedStatus,
      reminderHour: habit.reminderHour,
      reminderMinute: habit.reminderMinute,
      category: habit.category,
      color: habit.color ?? Theme.of(context).primaryColor,
    );
    
    // Award points if completed
    // if (newStatus == true && currentStatus != true) {
    //   GamificationService().addPoints(5, 'habit_completed');
    // }
  }
  
  // Convert box data to Habit objects
  List<Habit> _boxToHabitList(Box box) {
    return box.values.map((data) {
      return Habit(
        id: data['id'],
        name: data['name'],
        dailyStatus: Map<String, bool?>.from(data['dailyStatus']),
        selectedWeekdays: List<int>.from(data['weekdays']),
        reminderHour: data['reminderHour'],
        reminderMinute: data['reminderMinute'],
        category: data['category'],
        color: data['colorValue'] != null ? Color(data['colorValue']) : null,
      );
    }).toList();
  }
  
  // Date formatting helpers
  DateTime _truncateToDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
  
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  List<DateTime> _generate7Days(DateTime centralDate) {
    return List.generate(7, (index) => 
      centralDate.subtract(Duration(days: 3 - index))
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
  
  String _dayOfWeekLetter(int weekday) {
    switch (weekday) {
      case 1: return S.of(context).mondayShort;
      case 2: return S.of(context).tuesdayShort;
      case 3: return S.of(context).wednesdayShort;
      case 4: return S.of(context).thursdayShort;
      case 5: return S.of(context).fridayShort;
      case 6: return S.of(context).saturdayShort;
      case 7: return S.of(context).sundayShort;
      default: return '';
    }
  }
  
  String _formatTimeFromHourMinute(int hour, int minute) {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
}