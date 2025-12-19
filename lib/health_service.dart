class FakeHealthService {
  Map<String, dynamic> getDailyData() {
    return {
      "steps": 4820.0,
      "exerciseMinutes": 36.0,
      "sleepHours": 7.2,
      "remSleep": 1.5,
      "deepSleep": 0.7
    };
  }

  Map<String, dynamic> getWeeklyData() {
    return {
      "steps": [5200.0, 6100.0, 4300.0, 7000.0, 6500.0, 4800.0, 5700.0],
      "exerciseMinutes": [30.0, 40.0, 20.0, 55.0, 60.0, 25.0, 35.0],
      "sleepHours": [6.5, 7.0, 8.2, 7.5, 6.8, 7.9, 8.1],
      "remSleep": [0.9, 1.2, 1.4, 2.3, 0.7, 1.5, 1.7],
      "deepSleep": [0.7, 0.69, 0.8, 0.81, 0.67, 0.91, 0.72]
    };
  }
}
