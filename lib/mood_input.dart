import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morganalm/gemini_service.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MoodInputScreen extends StatefulWidget {
  const MoodInputScreen({super.key});

  @override
  State<MoodInputScreen> createState() => _MoodInputScreenState();
}

class _MoodInputScreenState extends State<MoodInputScreen> {
  double _selectedMood = 0.5; // 0 = sad, 1 = happy
  String? _note;
  final TextEditingController _noteController = TextEditingController();
  final FlutterTts tts = FlutterTts();

  /// Saves mood into local Firebase database
  void _saveMood() async {
    _note = _noteController.text.trim();

    // Convert slider value (0.0-1.0) to mood index (0-3)
    int moodIndex = (_selectedMood * 3).round();

    try {
      print("Attempting to put in database...");
      await FirebaseFirestore.instance.collection('moods').add({
        'mood': moodIndex,
        'note': _note,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mood saved successfully!')),
      );

      // Generate AI response
      await _generateAndShowAIResponse(moodIndex, _note);

      _noteController.clear();
      setState(() => _selectedMood = 0.5);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving mood: $e')),
      );
    }
  }

  /// Generate AI response after submitting a mood
  Future<void> _generateAndShowAIResponse(int mood, String? note) async {
    final ai = GeminiService();

    try {
      final response = await ai.generateResponse(mood, note);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Morgana:'),
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
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9B9B), // Coral pink background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9B9B),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Transform.rotate(
            angle: -0.2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Text(
                'CHECK-IN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        titleSpacing: 10,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFB85555),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile picture and speech bubble with question
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/ic_launcher.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Text(
                        'How are you doing today?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Mood slider with sad/happy faces
              Row(
                children: [
                  // Sad face
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB3B3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        '😞',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Slider
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 30,
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white,
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 20,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 30,
                        ),
                      ),
                      child: Slider(
                        value: _selectedMood,
                        onChanged: (value) {
                          setState(() => _selectedMood = value);
                        },
                        min: 0,
                        max: 1,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Happy face
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB3B3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        '😄',
                        style: TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Text input with microphone icon
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "What's on your mind?",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.mic, color: Colors.black),
                      onPressed: () {
                        // TODO: Add voice input functionality here
                      },
                    ),
                  ),
                  maxLines: 5,
                ),
              ),
              const SizedBox(height: 40),

              // Submit button
              ElevatedButton(
                onPressed: _saveMood,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }
}