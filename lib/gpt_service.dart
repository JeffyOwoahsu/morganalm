import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GPTService {
  final String? apiKey = dotenv.env['OPENAI_API_KEY'];

  Future<String> generateResponse(int moodIndex, String? note) async {
    final moods = ['sad', 'neutral', 'happy', 'excited'];
    final moodLabel = moods[moodIndex];
    final prompt = """
    You are MorganaLM, a friendly and empathetic AI mental health assistant.
    The user reports feeling $moodLabel today.
    Respond with one short, encouraging message that fits their emotional tone.
    If they added a note, consider it briefly.
    User note: "$note"
    """;

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-4o-mini', // fast + cheap for quick responses
      'messages': [
        {'role': 'system', 'content': 'You are a compassionate AI companion.'},
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 60,
      'temperature': 0.8,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print('Error: ${response.body}');
      return "Sorry, I'm having trouble responding right now.";
    }
  }
}
