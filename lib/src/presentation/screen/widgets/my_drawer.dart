import 'package:fabspinrider/src/controller/rider_controller.dart';
import 'package:fabspinrider/src/presentation/screen/account.dart';
import 'package:fabspinrider/src/presentation/screen/login_screen.dart';
import 'package:fabspinrider/src/presentation/screen/order_history.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final RiderController controller = Get.put(RiderController());

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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80),
                        color: Colors.white,
                      ),
                      child: const Center(
                          child: Icon(
                        Icons.person,
                        color: Colors.black,
                      )),
                    ),
                    Obx(
                      () => Text(
                        controller.name.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ));
          }),
          Column(
            children: [
              listTile(
                context,
                'Delivery History',
                Icons.delivery_dining_outlined,
                () {
                  Get.to(() => const OrderHistoryScreen());
                },
              ),
              listTile(
                context,
                'Account',
                Icons.person_4_outlined,
                () {
                  Get.to(() => const MyProfile());
                },
              ),
            ],
          ),
          Container(
            height: 1,
            color: Colors.black,
          ),
          Builder(builder: (c) {
            return listTile(
              context,
              'Log out',
              null,
              () async {
                Get.offAll(() => LoginScreen());
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.clear();
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
