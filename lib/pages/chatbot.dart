import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutterWidgets;
import 'package:hive_flutter/hive_flutter.dart';

// Für RevenueCat
import 'package:purchases_flutter/purchases_flutter.dart'; // für firstWhereOrNull

// Speech-To-Text
import 'package:speech_to_text/speech_to_text.dart' as stt;

// ElevenLabs + Audio
import 'package:audioplayers/audioplayers.dart';
import '../services/elevenlabs_service.dart';

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

  // Speech-To-Text
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // ElevenLabs
  late ElevenLabsService _elevenLabsService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _ttsEnabled = true;      // TTS default an
  String _selectedVoiceId = 'EXAVITQu4vr4xnSDxMaL'; // Deine Default-Voice (z.B. "Rachel" in ElevenLabs)

  bool _showScrollDownButton = false;
  final List<Map<String, String>> _messages = [];

  late Haertegrad _currentMode;

  @override
  void initState() {
    super.initState();

    // 1) STT initialisieren
    _speech = stt.SpeechToText();

    // 2) ElevenLabsService init
    //    Default Voice: "EXAVITQu4vr4xnSDxMaL" – diese ID kannst du ändern
    _elevenLabsService = ElevenLabsService(voiceId: _selectedVoiceId);

    // 3) Härtegrad aus Hive laden
    final int index = Hive.box('settings').get('haertegrad', defaultValue: 1);
    _currentMode = Haertegrad.values[index];

    // 4) Check 7-Tage-Prompts
    _checkAndResetPromptsIfNeeded();

    // 5) Scroll-Listener
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
    _speech.stop();

    // AudioPlayer und ElevenLabsService aufräumen (optional)
    _audioPlayer.dispose();

    super.dispose();
  }

  // ----------------------------------------------------
  // A) Speech-To-Text Logic
  // ----------------------------------------------------
  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint('STT onStatus: $status'),
      onError: (error) => debugPrint('STT onError: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
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

  // ----------------------------------------------------
  // B) ElevenLabs TTS
  // ----------------------------------------------------
  Future<void> _speakWithElevenLabs(String text) async {
    // Nur abfeuern, wenn TTS aktiviert
    if (!_ttsEnabled) return;

    // 1) Voice in Service anpassen, falls sich _selectedVoiceId geändert hat
    _elevenLabsService = ElevenLabsService(voiceId: _selectedVoiceId);

    // 2) Audio generieren
    final audioBytes = await _elevenLabsService.generateSpeechAudio(text);
    if (audioBytes == null) {
      debugPrint("Fehler: Audio kam leer zurück.");
      return;
    }

    // 3) Audio abspielen
    await _audioPlayer.play(BytesSource(audioBytes));
  }

  // ----------------------------------------------------
  // C) 7-Tage-Check
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // D) Nachricht senden (Chat)
  // ----------------------------------------------------
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Falls wir gerade lauschen, stoppen
    if (_isListening) {
      await _stopListening();
    }

    final settingsBox = Hive.box('settings');
    final isPremium = settingsBox.get('isPremium', defaultValue: false);
    int usedPrompts = settingsBox.get('chatPromptsUsed', defaultValue: 0);

    // => Hier z.B. 50 Prompt-Limit
    if (!isPremium && usedPrompts >= 50) {
      _showPaywallDialog();
      return;
    }
    settingsBox.put('chatPromptsUsed', usedPrompts + 1);

    // User-Message hinzufügen
    setState(() {
      _messages.add({'role': 'user', 'content': text});
    });
    _controller.clear();
    _scrollToBottom();

    try {
      // OpenAI holen
      final response = await _openAIService.sendMessage(text, _currentMode);

      // Leere Bot-Meldung
      setState(() {
        _messages.add({'role': 'bot', 'content': ''});
      });
      _scrollToBottom();

      // Typewriter
      for (int i = 0; i < response.length; i++) {
        await Future.delayed(const Duration(milliseconds: 3));
        setState(() {
          _messages[_messages.length - 1]['content'] =
              response.substring(0, i + 1);
        });
      }
      _scrollToBottom();

      // => ElevenLabs TTS
      await _speakWithElevenLabs(response);

    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'bot',
          'content': S.of(context).errorOccurred(e.toString()),
        });
      });
      _scrollToBottom();
    }
  }

  // ----------------------------------------------------
  // E) Scroll
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // F) Paywall / Kauf
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // G) Build
  // ----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');
    final usedPrompts = settingsBox.get('chatPromptsUsed', defaultValue: 0);
    final isPremium = settingsBox.get('isPremium', defaultValue: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daimonion Chat'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          // TTS-Toggle Button
          IconButton(
            onPressed: () {
              setState(() {
                _ttsEnabled = !_ttsEnabled;
              });
            },
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              color: _ttsEnabled ? Colors.redAccent : Colors.white,
            ),
            tooltip: 'ElevenLabs TTS ${_ttsEnabled ? 'ON' : 'OFF'}',
          ),
          // Voice-Auswahl
          IconButton(
            onPressed: _showVoiceSelectionSheet,
            icon: const Icon(Icons.more_vert),
            tooltip: 'ElevenLabs-Stimme auswählen',
          ),
        ],
      ),
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

  // ----------------------------------------------------
  // H) BottomSheet für Voice-Auswahl
  // ----------------------------------------------------
  void _showVoiceSelectionSheet() {
    // Beispiel: 2-3 Voice-IDs, die du in ElevenLabs angelegt hast
    final possibleVoices = [
      {
        "name": "Rachel (en)",
        "id": "EXAVITQu4vr4xnSDxMaL", // Standard ID
      },
      {
        "name": "Domi (de)",
        "id": "MFeD0UqfTS12Ckz3863A", // Beispiel, anpassen
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateSheet) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select ElevenLabs Voice",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: possibleVoices.length,
                    itemBuilder: (context, index) {
                      final voice = possibleVoices[index];
                      final voiceId = voice["id"]!;
                      final isSelected = (voiceId == _selectedVoiceId);

                      return ListTile(
                        title: Text(
                          voice["name"]!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.redAccent)
                            : null,
                        onTap: () {
                          setStateSheet(() {
                            _selectedVoiceId = voiceId;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 223, 27, 27),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ----------------------------------------------------
  // I) Animated Suggestions
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // J) Messages List
  // ----------------------------------------------------
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

  // ----------------------------------------------------
  // K) Input Bar (inkl. Mic-Button)
  // ----------------------------------------------------
  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Mikro-Button
          InkWell(
            onTap: () async {
              if (_isListening) {
                await _stopListening();
              } else {
                await _startListening();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
                border: Border.all(color: Colors.white54),
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 223, 27, 27),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
//        der Vorschläge nacheinander.
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
      // 1) Rein
      for (int i = 0; i <= suggestion.length; i++) {
        if (!mounted) return;
        setState(() {
          _currentText = suggestion.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 50));
      }
      // 2) Stehenlassen
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      // 3) Raus
      for (int i = suggestion.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() {
          _currentText = suggestion.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 20));
      }
      // 4) Weiter
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
