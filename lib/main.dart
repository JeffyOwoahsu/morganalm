import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:morganalm/mood_input.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:morganalm/dashboard.dart';
import 'notfication_handler.dart';
import 'package:morganalm/chat.dart';
import 'package:morganalm/home.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

late final String apiKey;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env to set up API
  await dotenv.load(fileName: ".env");
  String apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'default';
  Gemini.init(apiKey: apiKey, enableDebugging: true);

  // Initializations of time zones, notifications, and settings
  tz.initializeTimeZones();

  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));

  const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // When the user taps the notification → go to mood screen
      runApp(const MorganaLM(openMoodScreen: true));
    },
  );


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await NotificationHandler.scheduleDailyReminder();
  runApp(const MorganaLM());
}

class MorganaLM extends StatelessWidget {
  final bool openMoodScreen;
  const MorganaLM({super.key, this.openMoodScreen = false});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MorganaLM',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const HomeScreen(),
      //home: const DashboardScreen(),
      //home: openMoodScreen ? const MoodInputScreen() : const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
