// lib/pages/chatbot.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/openai_service.dart';
import '../haertegrad_enum.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final OpenAIService _openAIService = OpenAIService();
  final List<Map<String, String>> _messages = [];

  // Der aktuell aus Hive gelesene Mode
  late Haertegrad _currentMode;

  @override
  void initState() {
    super.initState();

    // Wir holen den Index aus Hive, defaultValue = 2 => brutalEhrlich
    final int index = Hive.box('settings').get('haertegrad', defaultValue: 1);
    _currentMode = Haertegrad.values[index];
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
    });
    _controller.clear();

    try {
      final response = await _openAIService.sendMessage(
        text,
        _currentMode, // <-- Nutzt den gerade gelesenen Mode
      );
      setState(() {
        _messages.add({'role': 'bot', 'content': response});
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'bot',
          'content': 'Ein Fehler ist aufgetreten: $e',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daimonion Chat'),
      ),
      body: Column(
        children: [
          // Nachrichtenliste
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final msg = _messages[index];
                final isUser = (msg['role'] == 'user');
                return Container(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.redAccent : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Eingabefeld + Senden
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Frag Daimonion was du willst...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.redAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
