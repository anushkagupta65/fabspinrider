import 'package:fabspinrider/src/controller/booking_controller.dart';
import 'package:fabspinrider/src/presentation/booking/screen/add_customer_screen.dart';
import 'package:fabspinrider/src/presentation/booking/screen/after_splash.dart';
import 'package:fabspinrider/src/presentation/order_report/order_report.dart';
import 'package:fabspinrider/src/presentation/screen/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSearch extends StatelessWidget {
  HomeSearch({super.key});

  final BookingController searchController = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final prefs = await SharedPreferences.getInstance();
      //     prefs.clear();
      //     Get.offAll(AfterSplash());
      //   },
      //   backgroundColor: Colors.black,
      //   child: const Text(
      //     "Logout",
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => searchController.filterItems(value),
                decoration: InputDecoration(
                  hintText: 'Search by name or number...',
                  hintStyle: TextStyle(color: Colors.grey.shade100),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.black,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (searchController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final items = searchController.filteredItems;
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserDashboardScreen(
                                      userId: item['id'],
                                      userName: item['name'],
                                    )));
                        print(item["id"]);
                      },
                      child: Card(
                        color: Colors.grey.shade100,
                        child: ListTile(
                          title: Text(item['name'] ?? 'Unknown'),
                          subtitle: Text(item['address'] ?? 'No Address'),
                          trailing: Text(item['phone'] ?? 'No phone'),
                          leading: const Icon(Icons.person_outline,
                              color: Colors.black),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.clear();
                      Get.offAll(AfterSplash());
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text("Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 8.0),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(const AddCustomerScreen(
                        calledFrom: "new-customer",
                      ));
                    },
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text("Add Customer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 8.0),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.to(BarcodeSearchScreen());
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text("Garment Image",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 8.0),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
