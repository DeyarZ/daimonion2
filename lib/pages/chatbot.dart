// lib/pages/chatbot.dart

// Für UTF8-Decode, falls nötig
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Für RevenueCat
import 'package:purchases_flutter/purchases_flutter.dart';
// für firstWhereOrNull

import '../services/openai_service.dart';
import '../haertegrad_enum.dart';
// Importiere deine generierte Lokalisierung (Pfad ggf. anpassen)
import '../l10n/generated/l10n.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final OpenAIService _openAIService = OpenAIService();
  final ScrollController _scrollController = ScrollController();

  // Variable, ob der Scroll-Down-Button angezeigt wird
  bool _showScrollDownButton = false;

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

    // 3) Scroll-Listener für den "Scroll-to-Bottom"-Button
    _scrollController.addListener(() {
      // Wenn wir 100 Pixel oder mehr von der untersten Position entfernt sind:
      if (_scrollController.offset <
          _scrollController.position.maxScrollExtent - 100) {
        if (!_showScrollDownButton) {
          setState(() {
            _showScrollDownButton = true;
          });
        }
      } else {
        if (_showScrollDownButton) {
          setState(() {
            _showScrollDownButton = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Scrollt zum Ende der Liste, falls möglich
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
    _scrollToBottom();

    try {
      // 3) Hole Bot-Antwort via OpenAI
      final response = await _openAIService.sendMessage(text, _currentMode);

      // 4) Leeren Bot-Reply einfügen
      setState(() {
        _messages.add({'role': 'bot', 'content': ''});
      });
      _scrollToBottom();

      // 5) Typewriter-Animation
      for (int i = 0; i < response.length; i++) {
        await Future.delayed(const Duration(milliseconds: 3));
        setState(() {
          _messages[_messages.length - 1]['content'] =
              response.substring(0, i + 1);
        });
      }
      _scrollToBottom();
    } catch (e) {
      // Fehlerfall
      setState(() {
        _messages.add({
          'role': 'bot',
          'content': S.of(context).errorOccurred(e.toString()),
        });
      });
      _scrollToBottom();
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
          title: Text(S.of(context).upgradeTitle),
          content: Text(S.of(context).upgradeContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.of(context).cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 223, 27, 27)),
              onPressed: () async {
                try {
                  final premiumPackage = await _getPremiumPackage();
                  if (premiumPackage == null) {
                    // Kein passendes Package => Fehler
                    _showErrorDialog();
                    return;
                  }

                  // => Kauf starten
                  final purchaserInfo =
                      await Purchases.purchasePackage(premiumPackage);

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
              child: Text(S.of(context).buyPremium),
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
          title: Text(S.of(context).errorTitle),
          content: Text(S.of(context).errorContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(S.of(context).ok),
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
          title: Text(S.of(context).successTitle),
          content: Text(S.of(context).successContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(S.of(context).ok),
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(S.of(context).appBarTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        // Tastatur wegkicken, wenn irgendwo getippt wird
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: kToolbarHeight + 20),
              // Chat-Bereich als Stack: Hier wird der Scroll-Down-Button überlagert
              Expanded(
                child: Stack(
                  children: [
                    _messages.isEmpty
                        ? _buildSuggestionsArea()
                        : _buildMessagesList(),
                    if (_showScrollDownButton)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                          onPressed: _scrollToBottom,
                          child: const Icon(Icons.arrow_downward, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
              // Anzeige der genutzten Prompts (falls nicht Premium)
              if (!isPremium)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    S.of(context).freePromptsCounter(usedPrompts),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              // Eingabefeld + Sendeknopf
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: _buildInputBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // E) Suggestions
  // ------------------------------------------------
  Widget _buildSuggestionsArea() {
    final suggestions = [
      S.of(context).suggestion1,
      S.of(context).suggestion2,
      S.of(context).suggestion3,
      S.of(context).suggestion4,
      S.of(context).suggestion5,
      S.of(context).suggestion6,
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
              backgroundColor: Colors.grey.shade800,
              selectedColor: const Color.fromARGB(255, 223, 27, 27),
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
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _messages.length,
      itemBuilder: (BuildContext context, int index) {
        final msg = _messages[index];
        final isUser = (msg['role'] == 'user');
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isUser ? const Color.fromARGB(255, 223, 27, 27) : Colors.grey.shade800,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                    isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight:
                    isUser ? Radius.zero : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              msg['content'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                hintText: S.of(context).hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          // Send-Button
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 223, 27, 27),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
