import 'dart:async';
import 'dart:io';                          // Für File
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutterWidgets;
import 'package:hive_flutter/hive_flutter.dart';

import 'package:path_provider/path_provider.dart'; // Für getTemporaryDirectory

// Für RevenueCat
import 'package:purchases_flutter/purchases_flutter.dart';
// Audio
import 'package:audioplayers/audioplayers.dart';

// Deine Services
import '../services/elevenlabs_service.dart';
import '../services/openai_service.dart';
import '../haertegrad_enum.dart';
// Lokalisierung
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

  // ElevenLabs
  late ElevenLabsService _elevenLabsService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Voice ON/OFF
  bool _voiceEnabled = true;    
  // Default Voice
  String _selectedVoiceId = '29vD33N1CtxCmqQRPOHJ';  // Clyde (en, deep)

  bool _showScrollDownButton = false;
  final List<Map<String, String>> _messages = [];

  // Härtegrad
  late Haertegrad _currentMode;

  @override
  void initState() {
    super.initState();

    // ElevenLabsService init
    _elevenLabsService = ElevenLabsService(voiceId: _selectedVoiceId);

    // Härtegrad laden
    final int index = Hive.box('settings').get('haertegrad', defaultValue: 1);
    _currentMode = Haertegrad.values[index];

    // 7-Tage-Check
    _checkAndResetPromptsIfNeeded();

    // Scroll-Listener
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

      if (_scrollController.position.userScrollDirection == AxisDirection.up) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ----------------------------------------------------
  // A) ElevenLabs VOICE (Audio abspielen via Temp-File)
  // ----------------------------------------------------
  Future<void> _speakWithElevenLabs(String text) async {
    // Falls Voice off: abbruch => keine API-Kosten
    if (!_voiceEnabled) return;

    // Voice anpassen, falls geändert
    _elevenLabsService = ElevenLabsService(voiceId: _selectedVoiceId);

    // Audio-Bytes
    final audioBytes = await _elevenLabsService.generateSpeechAudio(text);
    if (audioBytes == null || audioBytes.isEmpty) {
      debugPrint("Fehler: Leere Audio-Daten");
      return;
    }

    // In Temp-Datei
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/elevenlabs_${DateTime.now().millisecondsSinceEpoch}.mp3',
    );
    await tempFile.writeAsBytes(audioBytes, flush: true);

    // Abspielen
    try {
      await _audioPlayer.setSourceDeviceFile(tempFile.path);
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Audio Playback Error: $e');
    }
  }

  // ----------------------------------------------------
  // B) 7-Tage-Check
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
  // C) Nachricht senden
  // ----------------------------------------------------
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final settingsBox = Hive.box('settings');
    final isPremium = settingsBox.get('isPremium', defaultValue: false);
    int usedPrompts = settingsBox.get('chatPromptsUsed', defaultValue: 0);

    // Limit 5 Prompts
    if (!isPremium && usedPrompts >= 5) {
      _showPaywallDialog();
      return;
    }
    settingsBox.put('chatPromptsUsed', usedPrompts + 1);

    // User-Message in Liste
    setState(() {
      _messages.add({'role': 'user', 'content': text});
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _openAIService.sendMessage(text, _currentMode);

      // Bot-Message
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

      // Voice
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
  // D) Scroll
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
  // E) Paywall / Kauf
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
  // F) Build
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
          // Voice-Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _voiceEnabled = !_voiceEnabled;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _voiceEnabled ? const Color.fromARGB(255, 223, 27, 27) : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _voiceEnabled ? 'VOICE ON' : 'VOICE OFF',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Voice-Auswahl
          IconButton(
            onPressed: _showVoiceSelectionSheet,
            icon: const Icon(Icons.more_vert),
            tooltip: 'Voice auswählen',
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
                          backgroundColor: const Color.fromARGB(255, 223, 27, 27),
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
  // G) Voice-Auswahl
  // ----------------------------------------------------
  void _showVoiceSelectionSheet() {
    final possibleVoices = [
      // {
      //   "name": "Antoni (en, deep/male)",
      //   "id": "ErXwobaYiN019PkyyX3X",
      // },
      // {
      //   "name": "Elias (de, male)",
      //   "id": "21m00Tcm4TlvDq8ikWAM",
      // },
      {
        "name": "Clyde (en, deep/male)",
        "id": "29vD33N1CtxCmqQRPOHJ",
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
                    "Select Voice",
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
  // H) Animated Suggestions - Bubbles
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
  // I) Messages List
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
  // J) Input Bar
  // ----------------------------------------------------
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
// EXTRA: Animierte Vorschläge als Bubbles
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
      // Buchstabe für Buchstabe rein
      for (int i = 0; i <= suggestion.length; i++) {
        if (!mounted) return;
        setState(() {
          _currentText = suggestion.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 50));
      }
      // kurz warten
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      // raustippen
      for (int i = suggestion.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() {
          _currentText = suggestion.substring(0, i);
        });
        await Future.delayed(const Duration(milliseconds: 20));
      }
      // Nächster
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          _currentText,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
