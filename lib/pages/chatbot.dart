import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutterWidgets;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/elevenlabs_service.dart';
import '../services/openai_service.dart';
import '../haertegrad_enum.dart';
import '../l10n/generated/l10n.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final OpenAIService _openAIService = OpenAIService();
  final ScrollController _scrollController = ScrollController();

  // ElevenLabs
  late ElevenLabsService _elevenLabsService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Voice ON/OFF – Default jetzt auf OFF
  bool _voiceEnabled = false;
  // Default Voice
  String _selectedVoiceId = '29vD33N1CtxCmqQRPOHJ'; // Clyde (en, deep)

  bool _showScrollDownButton = false;
  final List<Map<String, String>> _messages = [];
  
  // Animations
  late AnimationController _inputBoxAnimationController;
  late Animation<double> _inputBoxAnimation;
  
  // Typing indicator
  bool _isTyping = false;
  
  // Theme colors
  late Color _primaryColor;
  late Color _accentColor;
  late Color _darkColor;
  late Color _lightColor;
  
  // Härtegrad
  late Haertegrad _currentMode;

  @override
  void initState() {
    super.initState();

    // Theme colors
    _primaryColor = const Color(0xFFDF1B1B); // Red accent
    _accentColor = const Color(0xFF2A2F4F); // Deep purple accent
    _darkColor = const Color(0xFF121212);   // Near black
    _lightColor = const Color(0xFFE0E0E0);  // Light gray

    // Lade Voice-Setting aus Hive (Default: false)
    _voiceEnabled = Hive.box('settings').get('voiceEnabled', defaultValue: false);

    // Setup animations
    _inputBoxAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _inputBoxAnimation = CurvedAnimation(
      parent: _inputBoxAnimationController,
      curve: Curves.easeOutQuad,
    );
    _inputBoxAnimationController.forward();

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
    _inputBoxAnimationController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------
  // A) ElevenLabs VOICE (Audio abspielen via Temp-File)
  // ----------------------------------------------------
  Future<void> _speakWithElevenLabs(String text) async {
    // Falls Voice off: Abbruch => keine API-Kosten
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

    // Limit 50 Prompts
    if (!isPremium && usedPrompts >= 50) {
      _showPaywallDialog();
      return;
    }
    settingsBox.put('chatPromptsUsed', usedPrompts + 1);

    // User-Message in Liste
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isTyping = true; // Show typing indicator
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _openAIService.sendMessage(text, _currentMode);

      // Bot-Message
      setState(() {
        _isTyping = false; // Hide typing indicator
        _messages.add({'role': 'bot', 'content': ''});
      });
      _scrollToBottom();

      // Typewriter-Effekt
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
        _isTyping = false; // Hide typing indicator
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
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _darkColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium graphic
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    size: 48,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  S.of(context).upgradeTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _lightColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Content
                Text(
                  S.of(context).upgradeContent,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _lightColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        S.of(context).cancel,
                        style: TextStyle(
                          color: _lightColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
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
                      child: Text(
                        S.of(context).buyPremium,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _darkColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            S.of(context).errorTitle,
            style: TextStyle(color: _lightColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            S.of(context).errorContent,
            style: TextStyle(color: _lightColor.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                S.of(context).ok,
                style: TextStyle(color: _primaryColor),
              ),
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
          backgroundColor: _darkColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            S.of(context).successTitle,
            style: TextStyle(color: _lightColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            S.of(context).successContent,
            style: TextStyle(color: _lightColor.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                S.of(context).ok,
                style: TextStyle(color: _primaryColor),
              ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_darkColor, const Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
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
                          backgroundColor: _primaryColor,
                          elevation: 4,
                          onPressed: _scrollToBottom,
                          child: const Icon(Icons.arrow_downward, size: 20),
                        ),
                      ),
                    if (_isTyping)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: _buildTypingIndicator(),
                      ),
                  ],
                ),
              ),
              if (!isPremium)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      S.of(context).freePromptsCounter(usedPrompts),
                      style: TextStyle(
                        color: _lightColor.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Custom App Bar (angepasst)
  // ----------------------------------------------------
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _darkColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Links: Kleineres Chat-Emoji
          Icon(
            Icons.chat,
            color: _primaryColor,
            size: 24,
          ),
          // Mitte: Schriftzug "Daimonion" in weiß und kleiner
          Text(
            "Daimonion",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Rechts: Aktionen (Voice Button etc.)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Voice Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _voiceEnabled = !_voiceEnabled;
                  });
                  Hive.box('settings').put('voiceEnabled', _voiceEnabled);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _voiceEnabled ? _primaryColor : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: _voiceEnabled
                        ? [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _voiceEnabled ? Icons.volume_up : Icons.volume_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _voiceEnabled ? 'ON' : 'OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Voice Selection Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings_voice, color: Colors.white),
                  onPressed: _showVoiceSelectionSheet,
                  tooltip: 'Voice auswählen',
                  iconSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // G) Voice-Auswahl - REDESIGNED
  // ----------------------------------------------------
  void _showVoiceSelectionSheet() {
    final possibleVoices = [
      {
        "name": "Clyde (en, deep/male)",
        "id": "29vD33N1CtxCmqQRPOHJ",
        "description": "Deep, authoritative male voice",
      },
      // Weitere Stimmen können hier hinzugefügt werden:
      /*
      {
        "name": "Antoni (en, deep/male)",
        "id": "ErXwobaYiN019PkyyX3X",
        "description": "Articulate male voice with natural tone",
      },
      {
        "name": "Elias (de, male)",
        "id": "21m00Tcm4TlvDq8ikWAM",
        "description": "German male voice with clear pronunciation",
      },
      */
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateSheet) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: _darkColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title
                  Row(
                    children: [
                      Icon(Icons.record_voice_over, color: _primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        "Select Voice",
                        style: TextStyle(
                          fontSize: 20,
                          color: _lightColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Voice List
                  ...possibleVoices.map((voice) {
                    final voiceId = voice["id"]!;
                    final isSelected = (voiceId == _selectedVoiceId);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? _accentColor.withOpacity(0.3) 
                            : Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected 
                            ? Border.all(color: _primaryColor, width: 2) 
                            : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          voice["name"]!,
                          style: TextStyle(
                            color: _lightColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          voice["description"] ?? "",
                          style: TextStyle(
                            color: _lightColor.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 16),
                              )
                            : null,
                        onTap: () {
                          setStateSheet(() {
                            _selectedVoiceId = voiceId;
                          });
                          
                          // Optional: Spiele ein kurzes Sample der ausgewählten Voice ab
                          // _speakSample(voiceId);
                        },
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            "Apply Voice",
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    ),
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
  // H) Animated Suggestions - Bubbles - REDESIGNED
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ersetze Icon durch Asset-Bild in rot
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icon/chat.png',
              width: 100,
              height: 100,
              color: Colors.red,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          
          // Überschrift ändern
          Text(
            "The Voice you should listen to.",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _lightColor,
            ),
          ),
          // Untertitel entfernen
          
          const SizedBox(height: 32),
          
          // Animated suggestions
          _AnimatedSuggestions(
            suggestions: suggestions,
            onSuggestionTap: (selectedText) {
              setState(() {
                _controller.text = selectedText;
              });
            },
            primaryColor: _primaryColor,
            darkColor: _darkColor,
            lightColor: _lightColor,
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Typing Indicator
  // ----------------------------------------------------
  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPulsingDot(0),
          const SizedBox(width: 4),
          _buildPulsingDot(300),
          const SizedBox(width: 4),
          _buildPulsingDot(600),
        ],
      ),
    );
  }
  
  Widget _buildPulsingDot(int delay) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // I) Messages List - REDESIGNED
  // ----------------------------------------------------
  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (BuildContext context, int index) {
        final msg = _messages[index];
        final isUser = (msg['role'] == 'user');
        final isFirstMessage = index == 0 || _messages[index - 1]['role'] != msg['role'];
        final isLastMessage = index == _messages.length - 1 || _messages[index + 1]['role'] != msg['role'];
        
        return Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isFirstMessage) const SizedBox(height: 8),
            
            // Avatar and Name for first message in group
            if (isFirstMessage)
              Padding(
                padding: EdgeInsets.only(
                  left: isUser ? 0 : 12,
                  right: isUser ? 12 : 0,
                  bottom: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isUser)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'D',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      isUser ? S.of(context).you : 'Daimonion',
                      style: TextStyle(
                        color: _lightColor.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Message bubble
            Container(
              margin: EdgeInsets.only(
                top: 2,
                bottom: 2,
                left: isUser ? 60 : 0,
                right: isUser ? 0 : 60,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? _accentColor.withOpacity(0.8) : Colors.grey.shade800,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser || !isFirstMessage ? 16 : 0),
                  topRight: Radius.circular(!isUser || !isFirstMessage ? 16 : 0),
                  bottomLeft: Radius.circular(isUser || !isLastMessage ? 16 : 0),
                  bottomRight: Radius.circular(!isUser || !isLastMessage ? 16 : 0),
                ),
              ),
              child: SelectableText(
                msg['content'] ?? '',
                style: TextStyle(
                  color: _lightColor,
                  fontSize: 15,
                ),
              ),
            ),
            
            if (isLastMessage) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------
  // J) Input Bar
  // ----------------------------------------------------
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _darkColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ScaleTransition(
        scale: _inputBoxAnimation,
        child: Row(
          children: [
            // Text Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: _lightColor),
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: S.of(context).typeMessage,
                    hintStyle: TextStyle(color: _lightColor.withOpacity(0.5)),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            
            // Send Button
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                color: Colors.white,
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Animated Suggestions Widget
// ----------------------------------------------------
class _AnimatedSuggestions extends StatefulWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTap;
  final Color primaryColor;
  final Color darkColor;
  final Color lightColor;

  const _AnimatedSuggestions({
    required this.suggestions,
    required this.onSuggestionTap,
    required this.primaryColor,
    required this.darkColor,
    required this.lightColor,
  });

  @override
  State<_AnimatedSuggestions> createState() => _AnimatedSuggestionsState();
}

class _AnimatedSuggestionsState extends State<_AnimatedSuggestions> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.suggestions.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (index * 100)),
      ),
    );

    _animations = _animationControllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      );
    }).toList();

    // Starte Animationen sequentiell
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 100)), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(
          widget.suggestions.length,
          (index) => ScaleTransition(
            scale: _animations[index],
            child: _buildSuggestionBubble(widget.suggestions[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionBubble(String text) {
    return GestureDetector(
      onTap: () => widget.onSuggestionTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.primaryColor.withOpacity(0.1),
          border: Border.all(color: widget.primaryColor.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: widget.lightColor.withOpacity(0.9),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// Extension method for firstWhereOrNull
extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
