// lib/pages/journal.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Deine Services
import '../services/db_service.dart';
import '../services/gamification_service.dart';
import '../l10n/generated/l10n.dart';

/// Model für Rückwärtskompatibilität
/// Mood = "none" anstatt "sad, neutral, happy"
class JournalEntry {
  String title;
  String content;
  DateTime date;
  String mood; // ungenutzt, bleibt "none"

  JournalEntry({
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
  });
}

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final DBService _dbService = DBService();

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(loc.journalTitle),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ValueListenableBuilder(
          valueListenable: _dbService.listenableJournal(),
          builder: (ctx, Box box, widget) {
            final entries = _boxToJournalList(box);
            if (entries.isEmpty) {
              return Center(
                child: Text(
                  loc.noJournalEntries,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            // Neueste oben
            entries.sort((a, b) => b.date.compareTo(a.date));

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Dismissible(
                  key: ValueKey('${entry.date}-${entry.title}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: const Color.fromARGB(255, 223, 27, 27),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _deleteEntry(index),
                  child: _buildJournalCard(entry, index),
                );
              },
            );
          },
        ),
      ),
      // Neues Journal via FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 223, 27, 27),
        child: const Icon(Icons.add),
        onPressed: _showNewEntrySheet,
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Build Journal Card
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Widget _buildJournalCard(JournalEntry entry, int index) {
    return InkWell(
      onTap: () => _showEditEntrySheet(entry, index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 44, 44, 44), const Color.fromARGB(255, 48, 48, 48)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            entry.title.isEmpty ? S.of(context).untitled : entry.title,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          subtitle: Text(
            _formatDate(entry.date),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ),
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Neuen Eintrag anlegen => BottomSheet
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _showNewEntrySheet() {
    final loc = S.of(context);
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(ctx).size.height * 0.75, // 3/4 Höhe
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titel-Feld
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: loc.journalTitleLabel,
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Großes Content-Feld
                Expanded(
                  child: TextField(
                    controller: contentCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      labelText: loc.journalContentLabel,
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27)),
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Save-Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () async {
                      final newEntry = JournalEntry(
                        title: titleCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        date: DateTime.now(),
                        mood: 'none', // Mood ignoren
                      );

                      if (newEntry.title.isEmpty && newEntry.content.isEmpty) {
                        // Nix eingetragen => schließ Sheet ohne zu speichern
                        Navigator.pop(ctx);
                        return;
                      }

                      await _saveNewEntry(newEntry);
                      Navigator.pop(ctx); // Sheet schließen
                    },
                    icon: const Icon(Icons.check),
                    label: Text(loc.save),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Existierenden Eintrag bearbeiten => BottomSheet
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void _showEditEntrySheet(JournalEntry entry, int index) {
    final loc = S.of(context);
    final titleCtrl = TextEditingController(text: entry.title);
    final contentCtrl = TextEditingController(text: entry.content);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(ctx).size.height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titel
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: loc.journalTitleLabel,
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Inhalt
                Expanded(
                  child: TextField(
                    controller: contentCtrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      labelText: loc.journalContentLabel,
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 223, 27, 27)),
                      ),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Update Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () async {
                      final updated = JournalEntry(
                        title: titleCtrl.text.trim(),
                        content: contentCtrl.text.trim(),
                        date: entry.date, // Datum unverändert
                        mood: 'none',
                      );

                      if (updated.title.isEmpty && updated.content.isEmpty) {
                        // Wenn beides leer => wir löschen lieber?
                        Navigator.pop(ctx);
                        return;
                      }

                      await _updateEntry(updated, index);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(loc.save),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // CRUD + XP
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Future<void> _saveNewEntry(JournalEntry entry) async {
    final data = {
      'title': entry.title,
      'content': entry.content,
      'mood': entry.mood, // "none"
      'date': entry.date.millisecondsSinceEpoch,
    };
    await _dbService.addJournalEntry(data);

    // 2 XP pro neuem Eintrag, max 2 am Tag => 4 XP
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
    // KEIN XP für Update
  }

  Future<void> _deleteEntry(int index) async {
    await _dbService.deleteJournalEntry(index);
  }

  /// Vergibt 2 XP pro neuem Journal-Eintrag, max 2 Einträge pro Tag => 4 XP/Tag
  Future<void> _awardDailyJournalXP() async {
    final settingsBox = Hive.box('settings');
    final now = DateTime.now();
    final todayString = '${now.year}-${now.month}-${now.day}';

    final storedDate = settingsBox.get('journalXpDay', defaultValue: '');
    var dailyCount = settingsBox.get('journalXpCount', defaultValue: 0) as int;

    if (storedDate != todayString) {
      dailyCount = 0;
      settingsBox.put('journalXpDay', todayString);
      settingsBox.put('journalXpCount', dailyCount);
    }

    if (dailyCount < 2) {
      // +2 XP
      GamificationService().addXPWithStreak(2);
      dailyCount++;
      settingsBox.put('journalXpCount', dailyCount);

      final left = 2 - dailyCount;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "+2 XP!$dailyCount/2, $left left today.)",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Limit reached!"),
        ),
      );
    }
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Box -> List<JournalEntry>
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  List<JournalEntry> _boxToJournalList(Box box) {
    final List<JournalEntry> entries = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data == null) continue;

      final title = data['title'] as String? ?? '';
      final content = data['content'] as String? ?? '';
      final mood = data['mood'] as String? ?? 'none';
      final dateMs = data['date'] as int?;
      final date = dateMs != null
          ? DateTime.fromMillisecondsSinceEpoch(dateMs)
          : DateTime.now();

      entries.add(JournalEntry(
        title: title,
        content: content,
        date: date,
        mood: mood,
      ));
    }
    return entries;
  }

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Datum formatieren
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  String _formatDate(DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '${date.day}.${date.month}.${date.year} - $hh:$mm';
  }
}
