import 'package:fabspinrider/screen/home_screen.dart';
import 'package:fabspinrider/screen/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/NotificationService.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isLogin = false;


  @override
  void initState() {
    super.initState();

    //_checkLoginStatus();
    login();


    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String title = message.notification!.title ?? "New Pickup Order";
        String body = message.notification!.body ?? "You have a new order.";
        NotificationService().showNotification(title, body);
      }
    });

    // Request permissions for iOS
    //_firebaseMessaging.requestPermission();



  }

  void login() async{
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId != null) {

      Get.offAll(() =>HomeScreen());
    } else {
      // User is not logged in
      Get.offAll(() =>LoginScreen());
    }

  }
  // _promo()async{
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   pref.setBool('is_first_loaded', true);
  // }

  // Future<void> _checkLoginStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  //   print("isloggedIn ${isLoggedIn}");
  //   await Future.delayed(const Duration(seconds: 3), () {});
  //   if (isLoggedIn) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const Home()),
  //     );
  //   } else {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const LoginScreen()),
  //     );
  //   }
  // }

  // Future<void> _checkLoginStatus() async {
  //   await Future.delayed(Duration(seconds: 2)); // Simulate splash screen delay
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getInt('user_id');
  //
  //   if (userId != null) {
  //
  //     // Navigator.pushReplacement(
  //     //   context,
  //     //   MaterialPageRoute(builder: (context) =>  Home()),
  //     // );
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) =>  Bottomnavigation()),
  //     );
  //     _promo();
  //   } else {
  //     // User is not logged in
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const LoginScreen()),
  //     );
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/icon/splash.png", width: double.infinity, height: 400,)
            // Image.network(
            //   Urls.splashLogo,
            //   width: 300,
            //   height: 300,
            // ),
          ],
        ),
      ),
    );
  }
}
