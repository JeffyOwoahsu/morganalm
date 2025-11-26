import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<String> generateResponse(int moodIndex, String? note) async {
    final moods = ['sad', 'neutral', 'happy', 'excited'];
    final mood = moods[moodIndex];

    final prompt = """
You are MorganaLM, a friendly emotional companion AI.
The user feels $mood today.
Their note: "$note"

Respond with one short, supportive message.
""";

    final parts = [Part.text(prompt)];
    final response = await Gemini.instance.prompt(parts: parts);

    return response?.output ?? "MorganaLM couldn't think of a response right now.";
  }
}
