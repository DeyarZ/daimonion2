import 'dart:async'; // Für Timer/Future
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutterWidgets;
import 'package:hive_flutter/hive_flutter.dart';

// Für RevenueCat
import 'package:purchases_flutter/purchases_flutter.dart';
// für firstWhereOrNull

import 'package:speech_to_text/speech_to_text.dart' as stt; // A) Import STT
import 'package:flutter_tts/flutter_tts.dart';             // B) Import TTS

import '../services/openai_service.dart';
import '../haertegrad_enum.dart';
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

  // Speech-To-Text
  late stt.SpeechToText _speech;         // STT Instanz
  bool _isListening = false;             // Ob wir gerade lauschen

  // Text-To-Speech
  final FlutterTts _flutterTts = FlutterTts();

  // Scroll-Down-Button
  bool _showScrollDownButton = false;

  final List<Map<String, String>> _messages = [];

  late Haertegrad _currentMode;

  @override
  void initState() {
    super.initState();

    // 1) STT initialisieren
    _speech = stt.SpeechToText();

    // 2) Härtegrad aus Hive laden
    final int index = Hive.box('settings').get('haertegrad', defaultValue: 1);
    _currentMode = Haertegrad.values[index];

    // 3) Check, ob 7 Tage seit dem Start der Free Prompts abgelaufen sind
    _checkAndResetPromptsIfNeeded();

    // 4) Scroll-Listener
    _scrollController.addListener(() {
      if (_scrollController.offset <
          _scrollController.position.maxScrollExtent - 100) {
        if (!_showScrollDownButton) {
          setState(() => _showScrollDownButton = true);
        }
      } else {
        if (_showScrollDownButton) {
          setState(() => _showScrollDownButton = false);
        }
      }

      // Tastatur wegkicken beim Scrollen nach oben
      if (_scrollController.position.userScrollDirection == AxisDirection.up) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _speech.stop();      // STT aufräumen
    _flutterTts.stop();  // TTS ggf. stoppen
    super.dispose();
  }

  // --------------------------------------------------------------------------------
  // A) Speech-to-Text
  // --------------------------------------------------------------------------------
  Future<void> _startListening() async {
    // Schau, ob SpeechToText bereit ist
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('STT onStatus: $status'),
      onError: (error) => debugPrint('STT onError: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          // Alles, was reinkommt, in den _controller schreiben
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    } else {
      debugPrint("Speech Recognition ist nicht verfügbar.");
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  // --------------------------------------------------------------------------------
  // B) Text-to-Speech
  // --------------------------------------------------------------------------------
  Future<void> _speak(String text) async {
    // Optional: TTS-Parameter setzen (Sprache, Sprechgeschwindigkeit etc.)
    // await _flutterTts.setLanguage("de-DE");
    // await _flutterTts.setPitch(1.0);
    // await _flutterTts.setSpeechRate(0.95);

    await _flutterTts.speak(text);
  }

  // --------------------------------------------------------------------------------
  // C) Prompt-Reset-Logik
  // --------------------------------------------------------------------------------
  void _checkAndResetPromptsIfNeeded() {
    final settings = Hive.box('settings');
    final startMillis = settings.get('freePromptStart', defaultValue: 0);

    if (startMillis == 0) {
      settings.put('freePromptStart', DateTime.now().millisecondsSinceEpoch);
      return;
    }

    final startDate = DateTime.fromMillisecondsSinceEpoch(startMillis);
    final difference = DateTime.now().difference(startDate).inDays;

    if (difference >= 7) {
      settings.put('chatPromptsUsed', 0);
      settings.put('freePromptStart', DateTime.now().millisecondsSinceEpoch);
    }
  }

  // --------------------------------------------------------------------------------
  // D) Nachricht senden (Text)
  // --------------------------------------------------------------------------------
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Falls Mikro an: wir stoppen es, wenn man manuell sendet
    if (_isListening) {
      await _stopListening();
    }

    final settingsBox = Hive.box('settings');
    final isPremium = settingsBox.get('isPremium', defaultValue: false);
    int usedPrompts = settingsBox.get('chatPromptsUsed', defaultValue: 0);

    // Paywall-Check
    if (!isPremium && usedPrompts >= 5) {
      _showPaywallDialog();
      return;
    }

    // Prompt-Counter +1
    settingsBox.put('chatPromptsUsed', usedPrompts + 1);

    // User-Message einfügen
    setState(() {
      _messages.add({'role': 'user', 'content': text});
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // Bot-Antwort holen
      final response = await _openAIService.sendMessage(text, _currentMode);

      // Leeren Bot-Reply erstmal hinzufügen
      setState(() {
        _messages.add({'role': 'bot', 'content': ''});
      });
      _scrollToBottom();

      // Typewriter-Animation
      for (int i = 0; i < response.length; i++) {
        await Future.delayed(const Duration(milliseconds: 3));
        setState(() {
          _messages[_messages.length - 1]['content'] =
              response.substring(0, i + 1);
        });
      }
      _scrollToBottom();

      // Am Ende: Bot-Antwort vorlesen (falls gewünscht)
      // Optional: Kannst du an eine Setting knüpfen oder so
      await _speak(response);

    } catch (e) {
      // Fehler
      setState(() {
        _messages.add({
          'role': 'bot',
          'content': S.of(context).errorOccurred(e.toString()),
        });
      });
      _scrollToBottom();
    }
  }

  // --------------------------------------------------------------------------------
  // E) Scroll
  // --------------------------------------------------------------------------------
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

  // --------------------------------------------------------------------------------
  // F) Paywall / Kauf
  // --------------------------------------------------------------------------------
  Future<Package?> _getPremiumPackage() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 27, 27),
              ),
              onPressed: () async {
                try {
                  final premiumPackage = await _getPremiumPackage();
                  if (premiumPackage == null) {
                    _showErrorDialog();
                    return;
                  }

                  final purchaserInfo =
                      await Purchases.purchasePackage(premiumPackage);

                  if (purchaserInfo.entitlements.all["premium"]?.isActive == true) {
                    Hive.box('settings').put('isPremium', true);
                    Navigator.pop(ctx);
                    _showSuccessDialog();
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

  // --------------------------------------------------------------------------------
  // G) Build
  // --------------------------------------------------------------------------------
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
              Expanded(
                child: Stack(
                  children: [
                    _messages.isEmpty
                        ? _buildAnimatedSuggestionsArea()
                        : _buildMessagesList(),
                    if (_showScrollDownButton)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor:
                              const Color.fromARGB(255, 223, 27, 27),
                          onPressed: _scrollToBottom,
                          child: const Icon(Icons.arrow_downward, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isPremium)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    S.of(context).freePromptsCounter(usedPrompts),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
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

  // --------------------------------------------------------------------------------
  // H) Animated Suggestions
  // --------------------------------------------------------------------------------
  Widget _buildAnimatedSuggestionsArea() {
    final suggestions = [
      S.of(context).suggestion1,
      S.of(context).suggestion2,
      S.of(context).suggestion3,
      S.of(context).suggestion4,
      S.of(context).suggestion5,
      S.of(context).suggestion6,
    ];

    return Center(
      child: _AnimatedSuggestions(
        suggestions: suggestions,
        onSuggestionTap: (selectedText) {
          setState(() {
            _controller.text = selectedText;
          });
        },
      ),
    );
  }

  // --------------------------------------------------------------------------------
  // I) Messages List
  // --------------------------------------------------------------------------------
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
              color: isUser
                  ? const Color.fromARGB(255, 223, 27, 27)
                  : Colors.grey.shade800,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(16),
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

  // --------------------------------------------------------------------------------
  // J) Input Bar (inkl. Mic-Button)
  // --------------------------------------------------------------------------------
  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Mikro-Button
          InkWell(
            onTap: () async {
              if (_isListening) {
                // Wenn wir schon lauschen, stoppen
                await _stopListening();
              } else {
                // Ansonsten starten
                await _startListening();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),

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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

// --------------------------------------------------------
// EXTRA: Eigenes Widget für animiertes Anzeigen
//        der Vorschläge nacheinander (unverändert).
// --------------------------------------------------------
class _AnimatedSuggestions extends StatefulWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  const _AnimatedSuggestions({
    Key? key,
    required this.suggestions,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  State<_AnimatedSuggestions> createState() => _AnimatedSuggestionsState();
}

class _AnimatedSuggestionsState extends State<_AnimatedSuggestions> {
  int _currentIndex = 0;
  String _currentText = "";
  Timer? _cycleTimer;

  @override
  void initState() {
    super.initState();
    _startCycle();
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    super.dispose();
  }

  void _startCycle() {
    _cycle();
  }

  Future<void> _cycle() async {
    while (mounted) {
      final suggestion = widget.suggestions[_currentIndex];
      // Rein
      for (int i = 0; i <= suggestion.length; i++) {
        if (!mounted) return;
        setState(() {
          _currentText = suggestion.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 50));
      }
      // Stehenlassen
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      // Raus
      for (int i = suggestion.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() {
          _currentText = suggestion.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 20));
      }
      // Weiter
      _currentIndex = (_currentIndex + 1) % widget.suggestions.length;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final fullSuggestion = widget.suggestions[_currentIndex];
        widget.onSuggestionTap(fullSuggestion);
      },
      child: Text(
        _currentText,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
