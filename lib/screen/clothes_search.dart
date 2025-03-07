import 'package:fabspinrider/booking/controller/booking_controller.dart';
import 'package:fabspinrider/screen/widgets/booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClothesSearch extends StatefulWidget {
  final userId;
  final userName;

  ClothesSearch({super.key, required this.userId, required this.userName});

  @override
  _ClothesSearchState createState() => _ClothesSearchState();
}

class _ClothesSearchState extends State<ClothesSearch> {
  final BookingController searchController = Get.put(BookingController());

  final List<Map<String, dynamic>> selectedClothes = [];

  void toggleSelection(Map<String, dynamic> item) {
    setState(() {
      if (selectedClothes.contains(item)) {
        selectedClothes.remove(item);
      } else {
        selectedClothes.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) =>
                    searchController.searchClothes("3", value),
                decoration: InputDecoration(
                  hintText: 'Search clothes for ${widget.userName}...',
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

                final items = searchController.clothesSearched;
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'No clothes found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = selectedClothes.contains(item);

                    return InkWell(
                      onTap: () => toggleSelection(item),
                      child: Card(
                        color: isSelected
                            ? Colors.blue.shade100
                            : Colors.grey.shade100,
                        child: ListTile(
                          title: Text(
                            "${item['service_name']} - ${item['subtrade_name']} - ${item['cloth_name']}",
                          ),
                          subtitle:
                              Text('Price: ${item['standerd_price'] ?? 'N/A'}'),
                          leading:
                              const Icon(Icons.checkroom, color: Colors.black),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : const Icon(Icons.check_circle_outline,
                                  color: Colors.black),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            if (selectedClothes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(BookingScreen(
                      selectedClothes: selectedClothes,
                      userId: widget.userId,
                      userName: widget.userName,
                    ));
                  },
                  child:
                      Text('Proceed to Next Page (${selectedClothes.length})'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// import 'package:fabspinrider/booking/controller/booking_controller.dart';
// import 'package:fabspinrider/screen/widgets/booking_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ClothesSearch extends StatefulWidget {
//   final userId;
//   ClothesSearch({super.key, required this.userId});

//   @override
//   _ClothesSearchState createState() => _ClothesSearchState();
// }

// class _ClothesSearchState extends State<ClothesSearch> {
//   final BookingController searchController = Get.put(BookingController());

//   // List to keep track of selected clothes
//   final List<Map<String, dynamic>> selectedClothes = [];

//   // Method to toggle the selection of clothes
//   void toggleSelection(Map<String, dynamic> item) {
//     setState(() {
//       if (selectedClothes.contains(item)) {
//         selectedClothes.remove(item);
//       } else {
//         selectedClothes.add(item);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: TextField(
//                 style: const TextStyle(color: Colors.white),
//                 onChanged: (value) =>
//                     searchController.searchClothes("3", value),
//                 decoration: InputDecoration(
//                   hintText: 'Search clothes by name...',
//                   hintStyle: const TextStyle(color: Colors.grey),
//                   prefixIcon: const Icon(Icons.search, color: Colors.white),
//                   filled: true,
//                   fillColor: Colors.black,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: Obx(() {
//                 if (searchController.isLoading.value) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }

//                 final items = searchController.clothesSearched;
//                 if (items.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'No clothes found',
//                       style: TextStyle(fontSize: 18, color: Colors.grey),
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     final item = items[index];
//                     final isSelected = selectedClothes.contains(item);

//                     return InkWell(
//                       onTap: () => toggleSelection(item),
//                       child: Card(
//                         color: isSelected
//                             ? Colors.blue.shade100
//                             : Colors.grey.shade100,
//                         child: ListTile(
//                           title: Text(
//                             "${item['service_name']} - ${item['subtrade_name']} - ${item['cloth_name']}",
//                           ),
//                           subtitle:
//                               Text('Price: ${item['standerd_price'] ?? 'N/A'}'),
//                           leading:
//                               const Icon(Icons.checkroom, color: Colors.black),
//                           trailing: isSelected
//                               ? const Icon(Icons.check_circle,
//                                   color: Colors.green)
//                               : const Icon(Icons.check_circle_outline,
//                                   color: Colors.black),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//             // Show button to navigate to the next page when items are selected
//             if (selectedClothes.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Navigate to the next page with the selected clothes count
//                     Get.to(BookingScreen(
//                       selectedClothes: selectedClothes,
//                       userId: widget.userId,
//                     ));
//                   },
//                   child:
//                       Text('Proceed to Next Page (${selectedClothes.length})'),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
