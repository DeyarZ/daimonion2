import 'dart:convert';
import 'dart:typed_data';             // (a) <-- Das brauchst du für Uint8List
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ElevenLabsService {
  final String _apiUrl = 'https://api.elevenlabs.io/v1/text-to-speech';
  late final String _apiKey;
  final String voiceId;

  ElevenLabsService({this.voiceId = 'EXAVITQu4vr4xnSDxMaL'}) {
    // (b) Key aus .env lesen
    _apiKey = dotenv.get('ELEVENLABS_API_KEY', fallback: '');
  }

  Future<Uint8List?> generateSpeechAudio(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/$voiceId'),
        headers: {
          'xi-api-key': _apiKey,
          'Content-Type': 'application/json',
          'Accept': 'audio/mpeg',
        },
        body: jsonEncode({
          "text": text,
          "model_id": "eleven_multilingual_v2",
          "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.8,
          },
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes; // <= hier kommt dein Audio-Bytearray
      } else {
        // Aus debug-Zwecken Log ausgeben
        print("ElevenLabs Error ${response.statusCode}: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Fehler bei ElevenLabs-Anfrage: $e");
      return null;
    }
  }
}
