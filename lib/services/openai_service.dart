// lib/services/openai_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../haertegrad_enum.dart';
import '../daimonion_prompts.dart';

class OpenAIService {
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  late final String _apiKey;

  OpenAIService() {
    _apiKey = dotenv.get('OPENAI_API_KEY', fallback: '');
  }

  Future<String> sendMessage(String userMessage, Haertegrad mode) async {
    try {
      final systemPrompt = _getSystemPrompt(mode);

      final requestBody = {
        "model": "gpt-3.5-turbo", // oder "gpt-4"
        "messages": [
          {"role": "system", "content": systemPrompt},
          {"role": "user", "content": userMessage}
        ],
        "max_tokens": 256,
        "temperature": 0.7,
      };

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final content = responseData['choices'][0]['message']['content'];
        return content.trim();
      } else {
        return 'Error: ${response.statusCode} -> ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  String _getSystemPrompt(Haertegrad mode) {
    switch (mode) {
      case Haertegrad.normal:
        return normalPrompt;
      case Haertegrad.hart:
        return hardPrompt;
      case Haertegrad.brutalEhrlich:
        return brutalPrompt;
    }
  }
}
