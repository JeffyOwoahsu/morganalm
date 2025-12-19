class InsightService {
  String generateSleepInsights(List<double> values) {
    if (values.isEmpty) return "No sleep data available.";

    double avg = values.reduce((a, b) => a + b) / values.length;

    return """
Sleep summary:
- Average sleep: ${avg.toStringAsFixed(1)} hours
""";
  }

  String generateActivityInsights(List<double> steps, List<double> exercise) {
    if (steps.isEmpty || exercise.isEmpty) return "No activity data available.";

    // Analyze steps
    double avgSteps = steps.reduce((a, b) => a + b) / steps.length;


    // Analyze steps
    double avgExercise = exercise.reduce((a, b) => a + b) / exercise.length;

    return """
Activity summary:
- Average steps: ${avgSteps.toStringAsFixed(0)}
- Average exercise: ${avgExercise.toStringAsFixed(0)}
""";
  }
}
