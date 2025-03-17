import 'package:fabspinrider/src/presentation/booking/screen/booking_login.dart';
import 'package:fabspinrider/src/presentation/booking/screen/home_search.dart';
import 'package:fabspinrider/src/presentation/screen/home_screen.dart';
import 'package:fabspinrider/src/presentation/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../controller/booking_controller.dart';

class AfterSplash extends StatelessWidget {
  AfterSplash({super.key});
  final BookingController controller = Get.put(BookingController());
  late var userId;
  late var userIdRider;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('UserId') ?? 0;
      userIdRider = prefs.getInt('user_id') ?? 0;
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                print("Rider Usr id: $userIdRider");
                userIdRider != 0
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
              },
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey),
                child: const Center(
                  child: Text(
                    "Rider Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                print("User Id $userId");
                userId == 0
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookingLogin()),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeSearch()),
                      );
              },
              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey),
                child: const Center(
                  child: Text(
                    "Store Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
