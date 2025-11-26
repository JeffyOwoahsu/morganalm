import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morganalm/gemini_service.dart';
import 'package:flutter_tts/flutter_tts.dart';


class MoodInputScreen extends StatefulWidget {
  const MoodInputScreen({super.key});

  @override
  State<MoodInputScreen> createState() => _MoodInputScreenState();
}
/// Custom state class for moods
class _MoodInputScreenState extends State<MoodInputScreen> {
  int _selectedMood = 0; String? _note;
  final TextEditingController _noteController = TextEditingController();
  final FlutterTts tts = FlutterTts();

  /// Saves mood into local Firebase database
  void _saveMood() async {
    _note = _noteController.text.trim();

    try { // try to add to the database
      print("Attempting to but in database...");
      await FirebaseFirestore.instance.collection('moods').add({
        'mood': _selectedMood,
        'note': _note,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood saved successfully!')),
      );

      // Generate AI response
      await _generateAndShowAIResponse(_selectedMood, _note);

      _noteController.clear();
      setState(() => _selectedMood = 0);
    } catch (e) { // failure to upload to database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving mood: $e')),
      );
    }
  }

  /// Generate AI response after submitting a mood in the mood input screen
  Future<void> _generateAndShowAIResponse(int mood, String? note) async {
    final ai = GeminiService();

    try {
      final response = await ai.generateResponse(mood, note);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('MorganaLM says:'),
          content: Text(response),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      // Speak response aloud
      await tts.speak(response);
    } catch (e) {
      print('Error generating AI response: $e');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Error'),
          content: Text('Something went wrong while generating a response.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  /// Customizes speech
  Future<void> _setupTts() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.45); // slower, calm tone
    await tts.setPitch(1.0);
  }



  @override
  Widget build(BuildContext context) {
    final moods = ['😞', '😐', '🙂', '😄'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Check-in'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(moods.length, (i) {
                final isSelected = _selectedMood == i;

                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.blue : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Text(
                      moods[i],
                      style: TextStyle(
                        fontSize: 36,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add a short note (optional)',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _saveMood,
              icon: const Icon(Icons.save),
              label: const Text('Submit Mood'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
