import 'package:flutter/material.dart';
import 'package:morganalm/health_service.dart';
import 'package:morganalm/line_chart.dart';
import 'package:morganalm/gemini_service.dart';

final health = FakeHealthService();
final ai = GeminiService();

final weeklyData = health.getWeeklyData();
List<double> weeklySleep = weeklyData['sleepHours'].cast<double>();
List<double> weeklyREMSleep = weeklyData['remSleep'].cast<double>();
List<double> weeklyDeepSleep = weeklyData['deepSleep'].cast<double>();
List<double> weeklySteps = weeklyData['steps'].cast<double>();
List<double> weeklyExercise = weeklyData['exerciseMinutes'].cast<double>();

/// Declares Dashboard screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// State class for Dashboard
class _DashboardScreenState extends State<DashboardScreen> {
  String selectedRange = "Daily";
  int selectedDayIndex = 0;
  String selectedActivityMetric = "Steps";

  final List<String> dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  Future<String>? _aiSummaryFuture;

  @override
  void initState() {
    super.initState();
    // Generate AI summary once when screen initializes
    _aiSummaryFuture = ai.generateDashboardSummary(weeklySleep, weeklySteps, weeklyExercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffff8181),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "DASHBOARD",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Dropdown --- DAILY / WEEKLY / MONTHLY
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xffff4040),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedRange,
                underline: Container(),
                dropdownColor: Colors.redAccent.shade100,
                items: const [
                  DropdownMenuItem(value: "Daily", child: Text("DAILY")),
                  DropdownMenuItem(value: "Weekly", child: Text("WEEKLY")),
                ],
                onChanged: (value) {
                  setState(() => selectedRange = value!);
                },
              ),
            ),

            const SizedBox(height: 20),

            // Sleep Section with Day Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Sleep"),
                if (selectedRange == "Daily") _buildDayToggle(),
              ],
            ),
            _buildDataCard(height: 180, child: _buildSleepData()),

            const SizedBox(height: 20),

            // Activity Section with Metric Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Activity"),
                if (selectedRange == "Weekly") _buildActivityMetricToggle(),
              ],
            ),
            _buildDataCard(height: 200, child: _buildActivityData()),

            const Spacer(),

            _buildAISummary(),

          ],
        ),
      ),
    );
  }

  // ---- UI helpers ----

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDataCard({required double height, required Widget child}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  /// Day Toggle Widget
  Widget _buildDayToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xffff4040),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                selectedDayIndex = (selectedDayIndex - 1) % 7;
                if (selectedDayIndex < 0) selectedDayIndex = 6;
              });
            },
          ),
          const SizedBox(width: 8),
          Text(
            dayLabels[selectedDayIndex],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                selectedDayIndex = (selectedDayIndex + 1) % 7;
              });
            },
          ),
        ],
      ),
    );
  }

  // Activity Metric Toggle Widget
  Widget _buildActivityMetricToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xffff4040),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedActivityMetric,
        underline: Container(),
        dropdownColor: Colors.redAccent.shade100,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        items: const [
          DropdownMenuItem(value: "Steps", child: Text("STEPS")),
          DropdownMenuItem(value: "Exercise", child: Text("EXERCISE")),
        ],
        onChanged: (value) {
          setState(() => selectedActivityMetric = value!);
        },
      ),
    );
  }


  Widget _buildSleepData() {
    final idealREMSleepPerc = 0.25;
    final idealDeepSleepPerc = 0.2;
    String sleepQuality = "Error";

    if (selectedRange == "Daily") {
      // Determine sleep quality
      var sleep = weeklySleep[selectedDayIndex];
      var remSleep = weeklyREMSleep[selectedDayIndex];
      var deepSleep = weeklyDeepSleep[selectedDayIndex];
      var idealREMSleep = idealREMSleepPerc * sleep;
      var idealDeepSleep = idealDeepSleepPerc * sleep;

      if (remSleep >= idealREMSleep && deepSleep >= idealDeepSleep) {
        sleepQuality = "Good";
      } else {
        sleepQuality = "Poor";
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text("Today's Sleep: $sleep hours",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text("REM Sleep: $remSleep hours",
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text("Deep Sleep: $deepSleep hours",
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text("Quality: $sleepQuality",
              style: const TextStyle(fontSize: 18)),
        ],
      );
    }

    if (selectedRange == "Weekly") {
      return CustomLineChart(
        values: weeklySleep,
        labels: ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"],
        title: "Weekly Sleep Activity",
        verticalLabel: "Hours",
        color: Colors.red,
      );
    }

    return const Center(
      child: Text(
        "No sleep data yet",
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _buildActivityData() {
    if (selectedRange == "Daily") {

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Steps: ${weeklySteps[selectedDayIndex]}", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text("Exercise Time: ${weeklyExercise[selectedDayIndex]} minutes", style: const TextStyle(fontSize: 20)),
        ],
      );
    }

    if (selectedRange == "Weekly") {
      // Switch between steps and exercise based on selected metric
      final values = selectedActivityMetric == "Steps" ? weeklySteps : weeklyExercise;
      final title = selectedActivityMetric == "Steps"
          ? "Weekly Step Activity"
          : "Weekly Exercise Activity";
      final verticalLabel = selectedActivityMetric == "Steps"
          ? "Steps"
          : "Exercise Time (Minutes)";

      return CustomLineChart(
        values: values,
        labels: ["Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"],
        title: title,
        verticalLabel: verticalLabel,
        color: Colors.red,
      );
    }

    return const Center(
      child: Text(
        "No activity data yet",
        style: TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _buildAISummary() {
    return FutureBuilder(
      future: _aiSummaryFuture,
      builder: (context, snapshot) {
        String summary = "...";

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          summary = snapshot.data!;
        }

        return Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline,
                  color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}