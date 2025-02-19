import 'package:fabspinrider/controller/controller.dart';
import 'package:fabspinrider/screen/account.dart';
import 'package:fabspinrider/screen/login_screen.dart';
import 'package:fabspinrider/screen/order_history.dart';
import 'package:fabspinrider/screen/terms_condition.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatelessWidget {
   MyDrawer({super.key});
  
   RiderController controller = Get.put(RiderController());




  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Builder(builder: (c) {
            return DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(Icons.person, color: Colors.black,)
                    ),
                  ),
                  Obx(()=>
                     Text(
                      controller.name.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
                  // : GestureDetector(
                  // onTap: () {
                  //   Scaffold.of(c).closeDrawer();
                  // },
                  // child: const Column(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       'Sign up/Log in',
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.w700,
                  //       ),
                  //     ),
                  //   ],
                  // )),
            );
          }),
          Column(
            children: [
              listTile(
                context,
                'Delivery History',
                Icons.delivery_dining_outlined,
                    () {
                  Get.to(()=>OrderHistoryScreen());
                },
              ),
              // listTile(
              //   context,
              //   'Earnings',
              //   Icons.attach_money_rounded,
              //       () {},
              // ),
              // listTile(
              //   context,
              //   'Rating',
              //   Icons.star_border_purple500_outlined,
              //       () {},
              // ),
              //9990207309
              listTile(
                context,
                'Account',
                Icons.person_4_outlined,
                    () {
                  Get.to(()=>MyProfile());
                    },
              ),
            ],
          ),
          Container(
            height: 1,
            color: Colors.black,
          ),
          // listTile(
          //   context,
          //   'Settings',
          //   null,
          //       () {
          //     Navigator.pop(context);
          //   },
          // ),
          // listTile(
          //   context,
          //   'Terms & Conditions / Privacy',
          //   null,
          //       () {
          //         Get.to(()=> TermsAndConditionsPage());
          //   },
          // ),
          Builder(builder: (c) {
            return listTile(
              context,
              'Log out',
              null,
                  () async {
                    Get.offAll(()=> LoginScreen());
                    SharedPreferences pref = await SharedPreferences.getInstance();
                    pref.clear();

                // Scaffold.of(c).closeDrawer();
                // showDialog(
                //   context: c,
                //   builder: (ctx) => MyAlertDialog(
                //     title: 'Logging out?',
                //     subtitle:
                //     'Thanks for stopping by. See you again soon!',
                //     action1Name: 'Cancel',
                //     action2Name: 'Log out',
                //     action1Func: () {
                //       Navigator.pop(ctx);
                //     },
                //     action2Func: () {
                //       // ap.userSignOut();
                //       // Navigator.pop(ctx);
                //       // Navigator.pushNamedAndRemoveUntil(
                //       //   context,
                //       //   AuthenticationScreen.routeName,
                //       //       (route) => false,
                //       // );
                //     },
                 // ),
                //);
              },
            );
          })
        ],
      ),
    );
  }

  ListTile listTile(
      BuildContext context, String text, IconData? icon, VoidCallback onTap) {
    return icon == null
        ? ListTile(
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    )
        : ListTile(
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
      leading: Icon(
        icon,
        color: Colors.cyan,
      ),
      onTap: onTap,
    );
  }
}
