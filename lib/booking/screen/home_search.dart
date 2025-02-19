import 'package:fabspinrider/booking/controller/booking_controller.dart';
import 'package:fabspinrider/booking/screen/after_splash.dart';
import 'package:fabspinrider/screen/clothes_search.dart';
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
      floatingActionButton: FloatingActionButton(onPressed: () async{
        final prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Get.offAll(AfterSplash());
      }, backgroundColor: Colors.black, child: Text("Logout", style: TextStyle(color: Colors.white),),),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: TextStyle(color: Colors.white),
                onChanged: (value) => searchController.filterItems(value),
                decoration: InputDecoration(
                  hintText: 'Search by name or number...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.black,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (searchController.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final items = searchController.filteredItems;
                if (items.isEmpty) {
                  return Center(
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
                      onTap: (){

                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ClothesSearch(userId: item['id'],)));
                        print(item["id"]);
                      },
                      child: Card(
                        color: Colors.grey.shade100,
                        child: ListTile(
                          title: Text(item['name'] ?? 'Unknown'),
                          subtitle: Text(item['address'] ?? 'No Address'),
                          trailing: Text(item['phone'] ?? 'No phone'),
                          leading: Icon(Icons.person_outline, color: Colors.black),
                        ),
                      ),
                    );
                  },
                );


              }),
            ),
          ],
        ),
      ),
    );
  }
}
