// lib/onboarding/onboarding_todos.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../services/db_service.dart';
import '../onboarding/onboarding_finish.dart';
import '../l10n/generated/l10n.dart';

class OnboardingTodosPage extends StatefulWidget {
  const OnboardingTodosPage({Key? key}) : super(key: key);

  @override
  State<OnboardingTodosPage> createState() => _OnboardingTodosPageState();
}

class _OnboardingTodosPageState extends State<OnboardingTodosPage> {
  final TextEditingController _todoController = TextEditingController();
  final List<Map<String, dynamic>> _onboardingTodos = [];
  final _uuid = const Uuid();

  // 1) Vorschläge für To-Dos
  final List<String> _suggestions = [
    "10 Sit-Ups",
    "5 Minuten Meditation",
    "15 Minuten Lesen",
    "1 Glas Wasser trinken",
  ];

  @override
  void initState() {
    super.initState();
    // 2) Vorgefertigtes To-Do reinwerfen
    _onboardingTodos.add({
      'id': _uuid.v4(),
      'title': '10 Push-Ups',
      'completed': false,
      'deadline': DateTime.now().millisecondsSinceEpoch,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  // ---------------------------------------
  // To-Do hinzufügen
  // ---------------------------------------
  void _addTodo() {
    final title = _todoController.text.trim();
    if (title.isEmpty) return;
    _todoController.clear();

    final newTodo = {
      'id': _uuid.v4(),
      'title': title,
      'completed': false,
      'deadline': DateTime.now().millisecondsSinceEpoch,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };

    setState(() {
      _onboardingTodos.add(newTodo);
    });
  }

  // ---------------------------------------
  // To-Do entfernen
  // ---------------------------------------
  void _removeTodo(int index) {
    setState(() {
      _onboardingTodos.removeAt(index);
    });
  }

  // ---------------------------------------
  // Deadline ändern
  // ---------------------------------------
  Future<void> _pickDeadline(int index) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _onboardingTodos[index]['deadline'] = picked.millisecondsSinceEpoch;
      });
    }
  }

  // ---------------------------------------
  // Weiter => To-Dos speichern => Finish
  // ---------------------------------------
  Future<void> _goNext() async {
    final dbService = DBService();
    final box = await Hive.openBox<Map>(DBService.tasksBoxName);

    for (final todo in _onboardingTodos) {
      await dbService.addTask(todo);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingFinishPage()),
    );
  }

  // ---------------------------------------
  // UI
  // ---------------------------------------
  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              loc.onboardingTodosTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              loc.onboardingTodosSubheadline,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Vorschlags-Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestions.map((suggestion) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Bei Klick => in _todoController setzen
                        _todoController.text = suggestion;
                      },
                      child: Text(
                        suggestion,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: loc.newTodoHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _addTodo,
                  child: Text(
                    loc.addTodo,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _onboardingTodos.isEmpty
                  ? Center(
                      child: Text(
                        loc.noTodosAdded,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _onboardingTodos.length,
                      itemBuilder: (context, index) {
                        final todo = _onboardingTodos[index];
                        final deadline = DateTime.fromMillisecondsSinceEpoch(todo['deadline']);
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              todo['title'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              loc.dueOn(_formatDate(deadline)),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removeTodo(index),
                            ),
                            onTap: () => _pickDeadline(index),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _goNext,
              child: Text(
                loc.continueButton,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }
}
