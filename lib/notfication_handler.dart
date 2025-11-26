import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:morganalm/main.dart';

class NotificationHandler {
  static Future<void> scheduleDailyReminder() async {
    try{
      await notificationsPlugin.zonedSchedule(
        0,
        'Daily Check-In 💬',
        'Hey! How are you feeling today?',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_checkin_channel',
            'Daily Check-In',
            channelDescription: 'Reminds user to log mood daily',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print("Schedule Daily Reminder Success");
    }
    on PlatformException catch(e) {
      print("Platform Exception");
      print(e);
    }
  }

  static tz.TZDateTime _nextNotificationTimeInstance() {
    //final now = tz.TZDateTime.now(tz.local);
    // for testing purposes
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1));
    // Ideal implementation
    /*
    var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 9, 0); // 9:00 AM local time
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
     */
    return scheduledDate;
  }
}