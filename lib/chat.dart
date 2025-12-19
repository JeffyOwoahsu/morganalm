import 'package:flutter/material.dart';
import 'package:morganalm/health_service.dart';
import 'package:morganalm/gemini_service.dart';
import 'package:morganalm/insights_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();

  final ai = GeminiService();
  final health = FakeHealthService();
  final insights = InsightService();

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    // Morgana begins the conversation
    messages.add(
      ChatMessage(
        text: "Hey there — how are you feeling today?",
        isUser: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF8181),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Transform.rotate(
          angle: -0.1,
          child: Stack(
            children: [
              // Black border
              Text(
                "CHAT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 3
                    ..color = Colors.black,
                ),
              ),
              // White fill
              const Text(
                "CHAT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),

          // Input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  // ==================== CHAT INPUT BAR ====================
  /// Chat Input Bar
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFFFF8D8D),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "What are your thoughts?",
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          )
        ],
      ),
    );
  }

  // ====================== MESSAGE BUBBLES ======================

  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            _buildAvatar(),

          Flexible(
            child: Transform.rotate(
              angle: isUser ? -0.06 : 0.06,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUser ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isUser ? Colors.black : Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 42,
      height: 42,
      margin: const EdgeInsets.only(right: 8, left: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/ic_launcher.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ====================== TYPING INDICATOR ======================

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildAvatar(),
          Flexible(
            child: Transform.rotate(
              angle: 0.06,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(0),
                    const SizedBox(width: 4),
                    _buildDot(200),
                    const SizedBox(width: 4),
                    _buildDot(400),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return FutureBuilder(
          future: Future.delayed(Duration(milliseconds: delay)),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  shape: BoxShape.circle,
                ),
              );
            }
            return _AnimatedDot();
          },
        );
      },
    );
  }

  // ==================== SEND MESSAGE + AI REPLY ====================

  Future<void> _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
    });

    _controller.clear();
    _scrollToBottom();

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });
    _scrollToBottom();

    final weeklyData = health.getWeeklyData();
    List<double> weeklySleep = weeklyData['sleepHours'].cast<double>();
    List<double> weeklySteps = weeklyData['steps'].cast<double>();
    List<double> weeklyExercise = weeklyData['exerciseMinutes'].cast<double>();

    String aiResponse = await ai.generateChatResponse(text, messages, weeklySleep, weeklySteps, weeklyExercise);

    // Hide typing indicator
    setState(() {
      _isTyping = false;
      messages.add(ChatMessage(text: aiResponse, isUser: false));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

// ====================== ANIMATED DOT ======================

class _AnimatedDot extends StatefulWidget {
  const _AnimatedDot();

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}