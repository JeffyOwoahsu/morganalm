import 'dart:convert';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:morganalm/insights_service.dart';
import 'package:morganalm/chat.dart';

class GeminiService {
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<String> generateResponse(int moodIndex, String? note) async {
    final moods = ['sad', 'neutral', 'happy', 'excited'];
    final mood = moods[moodIndex];

    final prompt = """
You are MorganaLM, a friendly emotional companion AI.
The user feels $mood today.
Their note: "$note"

Respond with one short, supportive message. No emojis.
""";

    final parts = [Part.text(prompt)];
    final response = await Gemini.instance.prompt(parts: parts);

    return response?.output ?? "MorganaLM couldn't think of a response right now.";
  }

  Future<String> generateDashboardSummary(List<double> sleep, List<double> steps, List<double> exercise) async {
    // Get insights
    final insights = InsightService();
    String sleepInsights = insights.generateSleepInsights(sleep);
    String activityInsights = insights.generateActivityInsights(steps, exercise);
    print("Generating response...");

    final prompt = """
You are MorganaLM, a gentle mental wellness assistant.

Here is the user's average data for the week:

$sleepInsights
$activityInsights

Explain the user's overall well-being this week in a friendly, supportive tone. Keep it brief, 2 sentences, and under 30 words.
""";
    // TODO: refactor this (DRY)
    final parts = [Part.text(prompt)];
    final response = await Gemini.instance.prompt(parts: parts);

    return response?.output ?? "Here's how you've been doing lately.";
  }

  Future<String> generateChatResponse(String? userMessage, List<ChatMessage> messages, List<double> sleep, List<double> steps, List<double> exercise) async {
    // Build conversation memory
    String memory = "";
    for (var msg in messages.take(15)) {
      memory += msg.isUser
          ? "User: ${msg.text}\n"
          : "Morgana: ${msg.text}\n";
    }

    // Get insights
    // TODO: also violates DRY principle
    final insights = InsightService();
    String sleepInsights = insights.generateSleepInsights(sleep);
    String activityInsights = insights.generateActivityInsights(steps, exercise);

    final prompt = """
You are MorganaLM, a warm, empathetic AI wellness assistant.  
Respond to the user's message conversationally.

Conversation history:
$memory

User says: "$userMessage"

You also have access to their health metrics, but ONLY mention them if directly relevant:

$sleepInsights
$activityInsights

Now respond in a supportive, friendly tone. Keep it brief and under 3 sentences unless the user asks for more.
""";

    final parts = [Part.text(prompt)];
    final response = await Gemini.instance.prompt(parts: parts);

    return response?.output ?? "Sorry, I can't think of a response right now.";
  }

}
