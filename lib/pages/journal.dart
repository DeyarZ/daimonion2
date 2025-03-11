// lib/pages/journal.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Services
import '../services/db_service.dart';
import '../services/gamification_service.dart';
import '../l10n/generated/l10n.dart';

/// Model for backward compatibility
/// Mood = "none" instead of "sad, neutral, happy"
class JournalEntry {
  String title;
  String content;
  DateTime date;
  String mood; // e.g. "😔", "😐", "😊", "🥳" oder "none"

  JournalEntry({
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
  });
}

/// Verschiedene Filter/Such-Optionen
enum FilterType {
  last7Days,
  last30Days,
  thisYear,
  oldestFirst,
  newestFirst,
}

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> with SingleTickerProviderStateMixin {
  final DBService _dbService = DBService();
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;

  /// Neue Farbwerte mit etwas besserem Kontrast
  final Color _primaryColor = const Color(0xFFDF1B1B); // Rot
  final Color _accentColor = const Color(0xFFFF6F6F); // Helleres Rot
  final Color _cardColor = const Color(0xFF1E1E1E);   // Dunkles Grau (statt pures Schwarz)
  final Color _bgColor = const Color(0xFF000000);     // Schwarz

  /// Wir merken uns den aktuell gewählten Filter
  FilterType _filterType = FilterType.newestFirst;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          loc.journalTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_bgColor, _bgColor.withOpacity(0.85)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: _dbService.listenableJournal(),
            builder: (ctx, Box box, widget) {
              // Journal-Einträge laden
              final entries = _boxToJournalList(box);

              // Anwenden von Filter/Sortierung
              final filteredEntries = _applyFilter(entries);

              if (filteredEntries.isEmpty) {
                return _buildEmptyState(loc);
              }

              return AnimationLimiter(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 350),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildJournalItem(filteredEntries[index], index),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      // New Journal Entry Button
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          backgroundColor: _primaryColor,
          onPressed: _showNewEntrySheet,
          icon: const Icon(Icons.create_rounded),
          label: Text(loc.journalTitle),
          elevation: 4,
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Filter- und Sortierlogik
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  List<JournalEntry> _applyFilter(List<JournalEntry> entries) {
    // Kopie der ursprünglichen Liste
    List<JournalEntry> filtered = List.from(entries);

    switch (_filterType) {
      case FilterType.last7Days:
        final cutoff = DateTime.now().subtract(const Duration(days: 7));
        filtered = filtered.where((e) => e.date.isAfter(cutoff)).toList();
        // Standard: Neueste zuerst
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;

      case FilterType.last30Days:
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        filtered = filtered.where((e) => e.date.isAfter(cutoff)).toList();
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;

      case FilterType.thisYear:
        final startOfYear = DateTime(DateTime.now().year, 1, 1);
        filtered = filtered.where((e) => e.date.isAfter(startOfYear)).toList();
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;

      case FilterType.oldestFirst:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;

      case FilterType.newestFirst:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    return filtered;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Empty State Widget
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildEmptyState(S loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: _primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            loc.noJournalEntries,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Start your journey of reflection by adding your first entry",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showNewEntrySheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              "Create First Entry",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Build Journal Item
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildJournalItem(JournalEntry entry, int index) {
    final loc = S.of(context);
    final formattedDate = _formatDate(entry.date);
    final preview = entry.content.length > 100
        ? '${entry.content.substring(0, 100)}...'
        : entry.content;

    return Dismissible(
      key: ValueKey('${entry.date}-${entry.title}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade800,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: _cardColor,
            title: Text(
              "Delete Entry?",
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              "This action cannot be undone.",
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: _accentColor),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteEntry(index),
      child: GestureDetector(
        onTap: () => _showEditEntrySheet(entry, index),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and time in header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: _primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ),

              // Title and content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      entry.title.isEmpty ? loc.untitled : entry.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (entry.content.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      // Content preview
                      Text(
                        preview,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
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

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Filter Options
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  "Filter & Sort Entries",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Filter / Sort Options
              _buildFilterOption(
                context,
                Icons.calendar_month,
                "Last 7 days",
                FilterType.last7Days,
              ),
              _buildFilterOption(
                context,
                Icons.calendar_month,
                "Last 30 days",
                FilterType.last30Days,
              ),
              _buildFilterOption(
                context,
                Icons.calendar_today,
                "This year",
                FilterType.thisYear,
              ),
              _buildFilterOption(
                context,
                Icons.sort,
                "Oldest first",
                FilterType.oldestFirst,
              ),
              _buildFilterOption(
                context,
                Icons.sort,
                "Newest first",
                FilterType.newestFirst,
              ),

              const SizedBox(height: 8),

              // Close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    IconData icon,
    String label,
    FilterType type,
  ) {
    final isSelected = (_filterType == type);
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? _primaryColor : Colors.white.withOpacity(0.7),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: _primaryColor)
          : null,
      onTap: () {
        setState(() {
          _filterType = type;
        });
        Navigator.pop(context);
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Create New Entry => BottomSheet
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _showNewEntrySheet() {
    final loc = S.of(context);
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    // Track if content has been modified
    bool hasContent = false;

    // Track the selected mood (default: "😊")
    String selectedMood = "😊";

    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Hilfsfunktion für die Mood-Icons (nur Emojis)
            Widget buildMoodIcon(String emoji) {
              final isSelected = (selectedMood == emoji);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMood = emoji;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor.withOpacity(0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _primaryColor : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              );
            }

            return Padding(
              padding: MediaQuery.of(ctx).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(ctx).size.height * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header mit Close-Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "New Journal Entry",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Aktuelles Datum
                    Row(
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 16,
                          color: _primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Title Field
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: loc.journalTitleLabel,
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          hasContent = value.isNotEmpty || contentCtrl.text.isNotEmpty;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Content Field
                    Expanded(
                      child: TextField(
                        controller: contentCtrl,
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: loc.journalContentLabel,
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onChanged: (value) {
                          setState(() {
                            hasContent = value.isNotEmpty || titleCtrl.text.isNotEmpty;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Mood selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildMoodIcon("😔"),
                        buildMoodIcon("😐"),
                        buildMoodIcon("😊"),
                        buildMoodIcon("🥳"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasContent ? _primaryColor : Colors.grey.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: hasContent
                              ? () async {
                                  final newEntry = JournalEntry(
                                    title: titleCtrl.text.trim(),
                                    content: contentCtrl.text.trim(),
                                    date: DateTime.now(),
                                    mood: selectedMood,
                                  );

                                  await _saveNewEntry(newEntry);
                                  Navigator.pop(ctx);
                                }
                              : null,
                          icon: const Icon(Icons.check),
                          label: Text(
                            loc.save,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Edit Existing Entry => BottomSheet
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _showEditEntrySheet(JournalEntry entry, int index) {
    final loc = S.of(context);
    final titleCtrl = TextEditingController(text: entry.title);
    final contentCtrl = TextEditingController(text: entry.content);

    // lokale Kopie des aktuellen Moods
    String selectedMood = entry.mood;

    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget buildMoodIcon(String emoji) {
              final isSelected = (selectedMood == emoji);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMood = emoji;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor.withOpacity(0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? _primaryColor : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              );
            }

            return Padding(
              padding: MediaQuery.of(ctx).viewInsets,
              child: Container(
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(ctx).size.height * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header mit Close-Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Edit Journal Entry",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Datum
                    Row(
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 16,
                          color: _primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMMM d, y').format(entry.date),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Title Field
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        hintText: loc.journalTitleLabel,
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Content Field
                    Expanded(
                      child: TextField(
                        controller: contentCtrl,
                        style: const TextStyle(color: Colors.white),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: loc.journalContentLabel,
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Mood selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildMoodIcon("😔"),
                        buildMoodIcon("😐"),
                        buildMoodIcon("😊"),
                        buildMoodIcon("🥳"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        // Delete button
                        Expanded(
                          flex: 1,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.delete_outline),
                            label: const Text("Delete"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade300,
                              side: BorderSide(color: Colors.red.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: _cardColor,
                                  title: const Text(
                                    "Delete this entry?",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    "This action cannot be undone.",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: _accentColor),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _deleteEntry(index);
                                Navigator.pop(ctx);
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Save button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: Text(loc.save),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final updated = JournalEntry(
                                title: titleCtrl.text.trim(),
                                content: contentCtrl.text.trim(),
                                date: entry.date,
                                mood: selectedMood,
                              );

                              // Wenn alles leer => Nachfragen, ob löschen
                              if (updated.title.isEmpty && updated.content.isEmpty) {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: _cardColor,
                                    title: const Text(
                                      "Empty Entry",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: const Text(
                                      "Do you want to delete this empty entry?",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text(
                                          "No",
                                          style: TextStyle(color: _accentColor),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldDelete == true) {
                                  await _deleteEntry(index);
                                }
                                Navigator.pop(ctx);
                                return;
                              }

                              await _updateEntry(updated, index);
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // CRUD Operations + XP rewards
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<void> _saveNewEntry(JournalEntry entry) async {
    final data = {
      'title': entry.title,
      'content': entry.content,
      'mood': entry.mood,
      'date': entry.date.millisecondsSinceEpoch,
    };
    await _dbService.addJournalEntry(data);

    // Award XP and show animation
    await _awardDailyJournalXP();
  }

  Future<void> _updateEntry(JournalEntry entry, int index) async {
    final data = {
      'title': entry.title,
      'content': entry.content,
      'mood': entry.mood,
      'date': entry.date.millisecondsSinceEpoch,
    };
    await _dbService.updateJournalEntry(index, data);

    // Show update confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Entry updated"),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteEntry(int index) async {
    await _dbService.deleteJournalEntry(index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Entry deleted"),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Convert the raw Hive Box content to a list of JournalEntry models
  List<JournalEntry> _boxToJournalList(Box box) {
    final List<JournalEntry> entries = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      if (data != null) {
        entries.add(
          JournalEntry(
            title: data['title'] ?? '',
            content: data['content'] ?? '',
            date: DateTime.fromMillisecondsSinceEpoch(data['date'] ?? 0),
            mood: data['mood'] ?? 'none',
          ),
        );
      }
    }
    return entries;
  }

  /// Format the date to a short string for display
  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, y').format(date);
  }

  /// Award daily XP for journaling
  Future<void> _awardDailyJournalXP() async {
    await GamificationService().awardDailyJournalXP();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("You earned XP for journaling!"),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
