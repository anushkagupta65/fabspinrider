import 'dart:async';
import 'package:fabspinrider/src/controller/rider_controller.dart';
import 'package:fabspinrider/src/presentation/screen/add_clothes.dart';
import 'package:fabspinrider/src/presentation/screen/widgets/my_drawer.dart';
import 'package:fabspinrider/src/presentation/screen/widgets/order_card.dart';
import 'package:fabspinrider/src/presentation/widgets/my_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home-screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RiderController controller = Get.put(RiderController());

  List<String> tabChoices = ['New Orders', 'Accepted', 'Picked Up', 'Deny'];

  @override
  void initState() {
    super.initState();
    getUser();
    startOrderUpdateTimer();
    controller.getUser();
  }

  void getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getInt('user_id') ?? 0;
    controller.getPickupDropListData(userId);
  }

  void startOrderUpdateTimer() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Orders',
            style: TextStyle(fontSize: 16, color: Colors.white)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getUser();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 20, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text('Pickups: ${controller.pickCount.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    Obx(() => Text('Drops: ${controller.dropCount.value}',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15, top: 20),
                child: Text('All Orders',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 20, bottom: 8),
                child: SizedBox(
                  height: 35,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tabChoices.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          controller.updateSelectedTab(tabChoices[index]);
                        },
                        child: Obx(() => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              margin: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                color: controller.selectedTab.value ==
                                        tabChoices[index]
                                    ? Colors.black
                                    : Colors.transparent,
                                border:
                                    Border.all(width: 2, color: Colors.black),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tabChoices[index],
                                style: TextStyle(
                                  color: controller.selectedTab.value ==
                                          tabChoices[index]
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )),
                      );
                    },
                  ),
                ),
              ),
              Obx(
                () {
                  if (controller.filteredOrders.isEmpty) {
                    return const Center(child: Text('No orders found.'));
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: controller.filteredOrders.length,
                    itemBuilder: (context, index) {
                      var order = controller.filteredOrders[index];
                      return OrderCard(
                        order: order,
                        pickUpOrder: () {
                          if (controller.selectedTab.value == tabChoices[0]) {
                            controller.updatePickup(order.id);
                            openSnackbar(
                                context, 'Order Accepted', Colors.black);
                          } else if (controller.selectedTab.value ==
                              tabChoices[1]) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddClothes(order: order);
                              },
                            );
                          } else if (controller.selectedTab.value ==
                              tabChoices[2]) {
                          } else if (controller.selectedTab.value ==
                              tabChoices[3]) {}
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
