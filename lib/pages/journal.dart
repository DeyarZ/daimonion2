import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // AdMob import
import '../services/db_service.dart';

// ------------------------------------
// Model: JournalEntry
// ------------------------------------
class JournalEntry {
  String title;
  String content;
  DateTime date;
  String mood;

  JournalEntry({
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
  });
}

// ------------------------------------
// JournalPage
// ------------------------------------
class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final DBService _dbService = DBService();

  // Neue Variablen für Ads
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    // AdMob Banner laden
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd.dispose(); // Ad-Objekt sauber entfernen
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2524075415669673~7860955987', // Deine Anzeigenblock-ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _dbService.listenableJournal(),
            builder: (ctx, Box box, widget) {
              final entries = _boxToJournalList(box);

              if (entries.isEmpty) {
                return const Center(
                  child: Text(
                    'Noch keine Einträge im Journal',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];

                  return Dismissible(
                    key: ValueKey(entry.date.toIso8601String() + entry.title),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => _deleteEntry(index),
                    child: _buildListTile(entry, index),
                  );
                },
              );
            },
          ),
          if (_isAdLoaded)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _addNewEntry,
        child: const Icon(Icons.add),
      ),
    );
  }

  // -------------------------------------------------------------
  // Convert Box -> List<JournalEntry>
  // -------------------------------------------------------------
  List<JournalEntry> _boxToJournalList(Box box) {
    final List<JournalEntry> result = [];
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i) as Map?;
      if (data != null) {
        final title = data['title'] as String? ?? '';
        final content = data['content'] as String? ?? '';
        final mood = data['mood'] as String? ?? 'neutral';
        final dateMillis = data['date'] as int?;
        final date = dateMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(dateMillis)
            : DateTime.now();

        result.add(JournalEntry(
          title: title,
          content: content,
          date: date,
          mood: mood,
        ));
      }
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  // -------------------------------------------------------------
  // Build single tile
  // -------------------------------------------------------------
  Widget _buildListTile(JournalEntry entry, int index) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          entry.title.isEmpty ? '(Ohne Titel)' : entry.title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          _formatDate(entry.date),
          style: TextStyle(color: Colors.grey[400]),
        ),
        leading: _moodIcon(entry.mood),
        onTap: () => _openEntryDetails(entry, index),
      ),
    );
  }

  // -------------------------------------------------------------
  // Mood-Icon
  // -------------------------------------------------------------
  Widget _moodIcon(String mood) {
    IconData iconData;
    Color color;
    switch (mood) {
      case 'happy':
        iconData = Icons.sentiment_satisfied_alt;
        color = Colors.green;
        break;
      case 'sad':
        iconData = Icons.sentiment_dissatisfied;
        color = Colors.blue;
        break;
      case 'neutral':
      default:
        iconData = Icons.sentiment_neutral;
        color = Colors.grey;
        break;
    }
    return Icon(iconData, color: color);
  }

  // -------------------------------------------------------------
  // Datum formatieren
  // -------------------------------------------------------------
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}, '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // -------------------------------------------------------------
  // Detail / Bearbeitung
  // -------------------------------------------------------------
  void _openEntryDetails(JournalEntry entry, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => JournalDetailPage(
          entry: entry,
          onSave: (updated) async {
            await _updateEntry(updated, index);
          },
        ),
      ),
    );
  }

  void _addNewEntry() {
    final newEntry = JournalEntry(
      title: '',
      content: '',
      date: DateTime.now(),
      mood: 'neutral',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => JournalDetailPage(
          entry: newEntry,
          onSave: (savedEntry) async {
            await _saveNewEntry(savedEntry);
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // Hive-Operationen
  // -------------------------------------------------------------
  Future<void> _saveNewEntry(JournalEntry entry) async {
    final data = {
      'title': entry.title,
      'content': entry.content,
      'mood': entry.mood,
      'date': entry.date.millisecondsSinceEpoch,
    };
    await _dbService.addJournalEntry(data);
  }

  Future<void> _updateEntry(JournalEntry updated, int index) async {
    final data = {
      'title': updated.title,
      'content': updated.content,
      'mood': updated.mood,
      'date': updated.date.millisecondsSinceEpoch,
    };
    await _dbService.updateJournalEntry(index, data);
  }

  Future<void> _deleteEntry(int index) async {
    await _dbService.deleteJournalEntry(index);
  }
}

// ------------------------------------
// JournalDetailPage
// ------------------------------------
class JournalDetailPage extends StatefulWidget {
  final JournalEntry entry;
  final ValueChanged<JournalEntry> onSave;

  const JournalDetailPage({
    Key? key,
    required this.entry,
    required this.onSave,
  }) : super(key: key);

  @override
  _JournalDetailPageState createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends State<JournalDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedMood;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _contentController = TextEditingController(text: widget.entry.content);
    _selectedMood = widget.entry.mood;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    final updatedEntry = JournalEntry(
      title: _titleController.text.trim().isEmpty
          ? '(Ohne Titel)'
          : _titleController.text.trim(),
      content: _contentController.text,
      date: widget.entry.date, // Datum bleibt
      mood: _selectedMood,
    );
    widget.onSave(updatedEntry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.title.isEmpty
            ? 'Neuer Eintrag'
            : 'Eintrag bearbeiten'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _saveEntry,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Title
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Titel',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Mood-Auswahl
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Stimmung:', style: TextStyle(color: Colors.white)),
                DropdownButton<String>(
                  dropdownColor: Colors.grey[900],
                  value: _selectedMood,
                  items: <String>['happy', 'sad', 'neutral']
                      .map((mood) => DropdownMenuItem<String>(
                            value: mood,
                            child: Text(
                              mood,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedMood = val;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content
            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Inhalt',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
          ],
        ),
      ),

      // Kein FAB mehr => wir verlassen uns auf den IconButton in der AppBar
    );
  }
}
