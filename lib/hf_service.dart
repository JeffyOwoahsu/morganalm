import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HFService {
  final String? _apiKey = dotenv.env['HF_API_KEY'];
  final String _baseUrl = 'https://huggingface.co';

  Future<String> generateResponse(int moodIndex, String? note) async {
    final moods = ['sad', 'neutral', 'happy', 'excited'];
    final mood = moods[moodIndex];
    final prompt = """
    You are MorganaLM, a kind and empathetic AI companion that helps users reflect on their day.
    The user feels $mood today. Here’s their note: "$note"
    Reply with one short, encouraging message.
    """;

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'inputs': prompt}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty && data[0]['generated_text'] != null) {
        return data[0]['generated_text'];
      } else if (data is Map && data.containsKey('generated_text')) {
        return data['generated_text'];
      } else {
        return 'MorganaLM is thinking... but didn’t say anything.';
      }
    } else {
      print('Response: Error ${response.statusCode}: ${response.body}');
      return 'Sorry, MorganaLM had trouble responding right now.';
    }
  }
}
