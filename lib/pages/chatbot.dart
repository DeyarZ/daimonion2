// lib/pages/chatbot.dart

import 'dart:convert'; // Für UTF8-Decode, falls nötig
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Für RevenueCat
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:collection/collection.dart'; // für firstWhereOrNull

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

  // Aus Hive gelesener Härtegrad (normal, hart, brutalEhrlich)
  late Haertegrad _currentMode;

  @override
  void initState() {
    super.initState();

    // 1) Härtegrad aus Hive laden
    final int index = Hive.box('settings').get('haertegrad', defaultValue: 1);
    _currentMode = Haertegrad.values[index];

    // 2) Check, ob 7 Tage seit dem Start der Free Prompts abgelaufen sind
    _checkAndResetPromptsIfNeeded();
  }

  // ------------------------------------------------
  // A) Check & Reset Free Prompts alle 7 Tage
  // ------------------------------------------------
  void _checkAndResetPromptsIfNeeded() {
    final settings = Hive.box('settings');
    final startMillis = settings.get('freePromptStart', defaultValue: 0);

    if (startMillis == 0) {
      // Noch nie was benutzt? => Start jetzt
      settings.put('freePromptStart', DateTime.now().millisecondsSinceEpoch);
      return;
    }

    final startDate = DateTime.fromMillisecondsSinceEpoch(startMillis);
    final difference = DateTime.now().difference(startDate).inDays;

    if (difference >= 7) {
      // Reset
      settings.put('chatPromptsUsed', 0);
      settings.put('freePromptStart', DateTime.now().millisecondsSinceEpoch);
    }
  }

  // ------------------------------------------------
  // B) Senden der Nachricht
  // ------------------------------------------------
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final settingsBox = Hive.box('settings');
    final isPremium = settingsBox.get('isPremium', defaultValue: false);
    int usedPrompts = settingsBox.get('chatPromptsUsed', defaultValue: 0);

    // 1) Paywall-Check
    if (!isPremium && usedPrompts >= 5) {
      _showPaywallDialog();
      return;
    }

    // => free Prompt counter +1
    settingsBox.put('chatPromptsUsed', usedPrompts + 1);

    // 2) Zeige User-Message direkt
    setState(() {
      _messages.add({'role': 'user', 'content': text});
    });
    _controller.clear();

    try {
      // 3) Hole Bot-Antwort via OpenAI
      final response = await _openAIService.sendMessage(text, _currentMode);

      // 4) Leeren Bot-Reply einfügen
      setState(() {
        _messages.add({'role': 'bot', 'content': ''});
      });

      // 5) Typewriter-Animation
      for (int i = 0; i < response.length; i++) {
        await Future.delayed(const Duration(milliseconds: 3));
        setState(() {
          _messages[_messages.length - 1]['content'] =
              response.substring(0, i + 1);
        });
      }
    } catch (e) {
      // Fehlerfall
      setState(() {
        _messages.add({
          'role': 'bot',
          'content': 'Ein Fehler ist aufgetreten: $e',
        });
      });
    }
  }

  // ------------------------------------------------
  // C) Paywall & Kauf-Logik
  // ------------------------------------------------

  // Holt das "premium"-Package aus RevenueCat
  Future<Package?> _getPremiumPackage() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        // => Falls es ein "premium"-Paket gibt, nimm es
        final premiumPackage = offerings.current!.availablePackages.firstWhereOrNull(
          (pkg) => pkg.identifier == "premium",
        );
        return premiumPackage;
      }
    } catch (e) {
      debugPrint("Fehler beim Abrufen des Premium-Pakets: $e");
    }
    return null;
  }

  void _showPaywallDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Upgrade nötig"),
          content: const Text(
            "Du hast deine 5 kostenlosen Prompts verbraucht.\n\nHol dir jetzt die Premium-Version für unbegrenzte Chats!",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                try {
                  final premiumPackage = await _getPremiumPackage();
                  if (premiumPackage == null) {
                    // Kein passendes Package => Fehler
                    _showErrorDialog();
                    return;
                  }

                  // => Kauf starten
                  final purchaserInfo = await Purchases.purchasePackage(premiumPackage);

                  // => Check Entitlement
                  if (purchaserInfo.entitlements.all["premium"]?.isActive == true) {
                    Hive.box('settings').put('isPremium', true);
                    Navigator.pop(ctx);
                    _showSuccessDialog(); // => Erfolgsmeldung
                  }
                } catch (e) {
                  debugPrint("Fehler beim Kauf: $e");
                  _showErrorDialog();
                }
              },
              child: const Text("Premium kaufen"),
            ),
          ],
        );
      },
    );
  }

  // Fehler-Dialog
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Fehler'),
          content: const Text(
            'Es ist ein Fehler aufgetreten. Bitte versuche es später erneut.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Erfolg-Dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Erfolg'),
          content: const Text('Du hast erfolgreich Premium freigeschaltet!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------
  // D) Build
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');
    final usedPrompts = settingsBox.get('chatPromptsUsed', defaultValue: 0);
    final isPremium = settingsBox.get('isPremium', defaultValue: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daimonion Chat'),
      ),
      body: Column(
        children: [
          // 1) Messages oder Suggestions
          Expanded(
            child: _messages.isEmpty
                ? _buildSuggestionsArea()
                : _buildMessagesList(),
          ),

          // 2) Anzeige, wie viele Prompts schon genutzt (falls nicht Premium)
          if (!isPremium)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                'Kostenlose Prompts genutzt: $usedPrompts / 5',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

          // 3) Eingabefeld + Sendeknopf
          _buildInputBar(),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // E) Suggestions
  // ------------------------------------------------
  Widget _buildSuggestionsArea() {
    final suggestions = [
      "Ich fühle mich heute faul und unmotiviert.",
      "Ich weiß nicht, was ich mit meinem Tag anfangen soll.",
      "Ich möchte neue Gewohnheiten aufbauen, aber wie?",
      "Ich habe keine Lust zu trainieren. Überzeug mich!",
      "Womit kann ich heute anfangen, produktiver zu sein?",
      "Gib mir einen Tritt in den Hintern!",
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: suggestions.map((text) {
            return ChoiceChip(
              label: Text(text, style: const TextStyle(color: Colors.white)),
              selected: false,
              backgroundColor: Colors.grey[800],
              selectedColor: Colors.redAccent,
              onSelected: (_) {
                setState(() {
                  _controller.text = text;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // F) Messages List
  // ------------------------------------------------
  Widget _buildMessagesList() {
    return ListView.builder(
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
    );
  }

  // ------------------------------------------------
  // G) Input Bar
  // ------------------------------------------------
  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // TextField
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.multiline,
              maxLines: null,
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
          // Send-Button
          IconButton(
            icon: const Icon(Icons.send, color: Colors.redAccent),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
