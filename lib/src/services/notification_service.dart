import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Initialize notification channel
    await _initNotificationChannel();

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground: ${message.notification?.title}');
      if (message.notification != null) {
        showNotification(
          message.notification!.title ?? "New Pickup Order",
          message.notification!.body ?? "You have a new pickup order.",
        );
      }
    });
  }

  Future<void> _initNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pickup_orders_channel', // Channel ID
      'Pickup Orders', // Channel Name
      description: 'This channel is used for pickup order notifications.',
      importance: Importance.high,
      //sound: RawResourceAndroidNotificationSound('notification_sound'), // Correct file reference (no .mp3)
      sound: null, // This uses the system default sound

    );


    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }


  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pickup_orders_channel', // Channel ID
      'Pickup Orders', // Channel Name
      channelDescription: 'This channel is used for pickup order notifications.',
      importance: Importance.high,
      priority: Priority.high,
      //sound: RawResourceAndroidNotificationSound('notification_sound'), // Referencing the custom sound
      sound: null, // This uses the system default sound

      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }



  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    } else {
      print('User denied notification permissions');
    }
  }
}
