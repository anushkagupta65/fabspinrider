import 'package:fabspinrider/booking/screen/after_splash.dart';
import 'package:fabspinrider/controller/controller.dart';
import 'package:fabspinrider/widgets/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  RiderController controller = Get.put(RiderController());
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestNotificationPermissions();

  FirebaseMessaging.instance.getToken().then((token) {
    debugPrint("Firebase Token: $token");
    controller.updateFcm(userId.toString(), token.toString());
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fab Spin Rider',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: AfterSplash(),
    );
  }
}
