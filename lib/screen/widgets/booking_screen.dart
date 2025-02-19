import 'package:fabspinrider/booking/controller/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedClothes;
  final userId;

  BookingScreen(
      {super.key, required this.selectedClothes, required this.userId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late List<int> counters;
  late List<TextEditingController> controllers;
  late List<num> currentPrices;
  BookingController controller = Get.put(BookingController());
  String selectedids = '0';

  @override
  void initState() {
    super.initState();
    counters = List<int>.filled(widget.selectedClothes.length, 1);
    controllers = List<TextEditingController>.generate(
      widget.selectedClothes.length,
      (index) {
        final price =
            _parsePrice(widget.selectedClothes[index]['standerd_price']);
        return TextEditingController(text: price.toString());
      },
    );
    currentPrices = widget.selectedClothes
        .map((item) => _parsePrice(item['standerd_price']))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  num _parsePrice(dynamic price) {
    if (price is num) return price;
    if (price is String) return num.tryParse(price) ?? 0;
    return 0;
  }

  void _updatePrice(int index) {
    final price = currentPrices[index];
    final totalAmount = counters[index] * price;
    controllers[index].text = totalAmount.toStringAsFixed(2);
  }

  void prepareRequestBody(BookingController controller, List<int> itemIds) {
    final Map<String, dynamic> requestBody = {
      "addonname": {},
      "addonprice": {},
    };

    for (final clothId in itemIds) {
      if (controller.selectedAddonNames.containsKey(clothId)) {
        requestBody["addonname"][clothId.toString()] =
            controller.selectedAddonNames[clothId];
        requestBody["addonprice"][clothId.toString()] =
            controller.selectedAddonPrices[clothId];
      }
    }

    print("Request Body: $requestBody");
  }

  void showSearchDialog(BuildContext context, int clothIndex,
      BookingController controller, int id) {
    final TextEditingController searchController = TextEditingController();

    // Initialize selections for the cloth index
    controller.initializeClothSelections(clothIndex);
    print("id adter dialog   $id   ");

    Get.dialog(
      AlertDialog(
        title: Text('Search Addons'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Enter addon name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                controller.fetchAddons(query); // Fetch data on search
              },
            ),
            SizedBox(height: 20),
            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (controller.addons.isEmpty) {
                return Text('No addons found');
              }
              return SizedBox(
                width: double.maxFinite,
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.addons.length,
                  itemBuilder: (context, index) {
                    final addon = controller.addons[index];
                    final isSelected = controller.selectedAddonNames[id]
                            ?.contains(addon['name']) ??
                        false;

                    return CheckboxListTile(
                      title: Text(addon['name']),
                      subtitle: Text('Price: ${addon['price']}'),
                      value: isSelected,
                      onChanged: (value) {
                        final price =
                            (double.tryParse(addon['price']) ?? 0.0).floor();
                        if (value == true) {
                          // Add the item
                          controller.addAddonToCloth(id, addon['name'], price);
                          controller.finalizeSelections();
                          Navigator.pop(context);
                        } else {
                          // Remove the item
                          controller.removeAddonFromCloth(
                              id, addon['name'], price);
                          Navigator.pop(context);
                        }

                        controller.refreshSelections(); // Refresh the UI
                      },
                    );
                  },
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('Selected Addons for cloth $clothIndex:');
              print('Names: ${controller.selectedAddonNames[clothIndex]}');
              print('Prices: ${controller.selectedAddonPrices[clothIndex]}');
              Get.back();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void showRemarksDialog(BuildContext context, int index) {
    final TextEditingController remarksController = TextEditingController();

    // Ensure the remarks list is initialized for the given index
    controller.initializeRemarks(index);

    Get.dialog(
      AlertDialog(
        title: Text('Enter Remarks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                labelText: 'Remarks',
                border: OutlineInputBorder(),
                hintText: 'Enter your remarks here',
              ),
              maxLines: 3, // Adjust the number of lines based on expected input
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog without saving
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String remarks = remarksController.text.trim();
              if (remarks.isNotEmpty) {
                // Save the remarks for the given index
                controller.remarks[index] = remarks;
                controller.remarks.refresh(); // Notify observers of the change
                print('Remarks for index $index: ${controller.remarks[index]}');
                //Get.snackbar('Success', 'Remarks saved successfully');
                Get.back(); // Close the dialog
              } else {
                Get.snackbar('Error', 'Please enter some remarks');
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void Stain(int clothIndex) async {
    await controller.fetchStain();

    // Ensure selections are initialized for this cloth
    controller.initializeClothSelectionsstains(clothIndex);

    Get.dialog(
      AlertDialog(
        title: Text('Stains'),
        content: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.brands.isEmpty) {
            return Text('No stains available.');
          }
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.brands.length,
              itemBuilder: (context, index) {
                final brand = controller.brands[index];
                final isSelected =
                    controller.selectedStainIds[clothIndex] == brand['id'];

                return RadioListTile<int>(
                  value: brand['id'],
                  groupValue: controller.selectedStainIds[clothIndex],
                  onChanged: (value) {
                    // Set the selected stain ID for the specific cloth
                    controller.selectedStainIds[clothIndex] = value!;
                    controller.selectedStainIds
                        .refresh(); // Refresh the observable
                    Navigator.pop(context);
                  },
                  title: Text(brand['name']),
                );
              },
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () {
              // Print the selected stain ID for the cloth before closing the dialog
              print(
                  'Selected Stain for cloth $clothIndex: ${controller.selectedStainIds[clothIndex]}');
              Get.back();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void Defects(int clothIndex) async {
    await controller.fetchDefects();

    // Ensure selections are initialized for this cloth
    controller.initializeDefectSelections(clothIndex);

    Get.dialog(
      AlertDialog(
        title: Text('Defects'),
        content: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.defects.isEmpty) {
            return Text('No defects available.');
          }
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.defects.length,
              itemBuilder: (context, index) {
                final defect = controller.defects[index];
                final isSelected =
                    controller.selectedDefectIds[clothIndex] == defect['id'];

                return RadioListTile<int>(
                  value: defect['id'],
                  groupValue: controller.selectedDefectIds[clothIndex],
                  onChanged: (value) {
                    // Set the selected defect ID for the specific cloth
                    controller.selectedDefectIds[clothIndex] = value!;
                    controller.selectedDefectIds
                        .refresh(); // Refresh the observable
                    Navigator.pop(context);
                  },
                  title: Text(defect['remarks']),
                );
              },
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () {
              // Print the selected defect ID for the cloth before closing the dialog
              print(
                  'Selected Defect for cloth $clothIndex: ${controller.selectedDefectIds[clothIndex]}');
              Get.back();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void colors(int clothIndex) async {
    await controller.fetchColors();

    // Ensure selections are initialized for this cloth
    controller.initializeColorSelections(clothIndex);

    Get.dialog(
      AlertDialog(
        title: Text('Colors'),
        content: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.colors.isEmpty) {
            return Text('No colors available.');
          }
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.colors.length,
              itemBuilder: (context, index) {
                final color = controller.colors[index];
                final isSelected =
                    controller.selectedColorIds[clothIndex] == color['id'];

                return RadioListTile<int>(
                  value: color['id'],
                  groupValue: controller.selectedColorIds[clothIndex],
                  onChanged: (value) {
                    // Set the selected color ID for the specific cloth
                    controller.selectedColorIds[clothIndex] = value!;
                    controller.selectedColorIds
                        .refresh(); // Refresh the observable
                    Navigator.pop(context);
                  },
                  title: Text(color['name']),
                  secondary: Container(
                    height: 20,
                    width: 20,
                    color: hexToColor(color['code']),
                  ),
                );
              },
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () {
              // Print the selected color ID for the cloth before closing the dialog
              print(
                  'Selected Color for cloth $clothIndex: ${controller.selectedColorIds[clothIndex]}');
              Get.back();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Selected Clothes'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.selectedClothes.length,
                itemBuilder: (context, index) {
                  final item = widget.selectedClothes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${item['cloth_name']}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Price per item: ₹${currentPrices[index]}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Counter buttons
                              Flexible(
                                flex: 2,
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                      onPressed: () {
                                        if (counters[index] > 1) {
                                          setState(() {
                                            counters[index]--;
                                            _updatePrice(index);
                                          });
                                        }
                                      },
                                      child: const Icon(
                                        Icons.remove,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        counters[index].toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: const CircleBorder(),
                                        backgroundColor: Colors.black,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          counters[index]++;
                                          _updatePrice(index);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Editable price field
                              Flexible(
                                flex: 1,
                                child: SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: controllers[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      labelText: 'Total',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      final newPrice = num.tryParse(value);
                                      if (newPrice != null && newPrice > 0) {
                                        setState(() {
                                          currentPrices[index] = newPrice;
                                          _updatePrice(index);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GridView(
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 5,
                              childAspectRatio: 1.9,
                            ),
                            shrinkWrap: true,
                            children: [
                              InkWell(
                                onTap: () {
                                  Stain(index);
                                },
                                child: Container(
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10),
                                    child: Text('Stain'),
                                  )),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              // SizedBox(width: 10,),
                              InkWell(
                                onTap: () {
                                  colors(index);
                                },
                                child: Container(
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10),
                                    child: Text('Color'),
                                  )),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              // SizedBox(width: 10,),
                              InkWell(
                                onTap: () {
                                  Defects(index);
                                },
                                child: Container(
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10),
                                    child: Text('Defects'),
                                  )),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              // SizedBox(width: 10,),
                              InkWell(
                                onTap: () {
                                  showRemarksDialog(context, index);
                                },
                                child: Container(
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10),
                                    child: Text('Remarks'),
                                  )),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  final itemIds = widget.selectedClothes
                                      .map((item) {
                                        selectedids = item['id'];
                                        print('Mapped ID: $selectedids');

                                        // Check if the ID is a valid integer and not null
                                        if (selectedids is int) {
                                          return selectedids;
                                        } else if (selectedids is String) {
                                          // If id is a string, attempt to parse it
                                          final parsedId =
                                              int.tryParse(selectedids);
                                          if (parsedId != null) {
                                            return parsedId;
                                          } else {
                                            print(
                                                'Invalid ID string: $selectedids');
                                            return null;
                                          }
                                        } else {
                                          print(
                                              'Unknown ID type: $selectedids');
                                          return null;
                                        }
                                      })
                                      .where((id) =>
                                          id != null) // Filter out null values
                                      .toList()
                                      .cast<int>();
                                  showSearchDialog(context, index, controller,
                                      itemIds[index]);
                                },
                                child: Container(
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10),
                                    child: Text('Addons'),
                                  )),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  final storeId = prefs.getInt('StoreId');

                  if (storeId == null) {
                    print("Store ID is null");
                    return;
                  }

                  final itemIds = widget.selectedClothes
                      .map((item) {
                        final id = item['id'];
                        print('Mapped ID: $id');

                        // Check if the ID is a valid integer and not null
                        if (id is int) {
                          return id;
                        } else if (id is String) {
                          // If id is a string, attempt to parse it
                          final parsedId = int.tryParse(id);
                          if (parsedId != null) {
                            return parsedId;
                          } else {
                            print('Invalid ID string: $id');
                            return null;
                          }
                        } else {
                          print('Unknown ID type: $id');
                          return null;
                        }
                      })
                      .where((id) => id != null) // Filter out null values
                      .toList()
                      .cast<int>(); // Cast to List<int>

                  print('Final Item IDs: $itemIds');

                  final prices = currentPrices
                      .map((price) => price.toDouble())
                      .toList(); // Convert to List<double>
                  final quantities = counters;

                  // print("Item IDs: $itemIds");
                  // print("Prices: $prices");
                  // print("Quantities: $quantities");
                  // print(widget.selectedClothes);
                  // print(storeId);
                  // print(widget.userId);
                  // print('Selected Stain IDs: ${controller.selectedStainIds}');
                  // print('Selected Defect IDs: ${controller.selectedDefectIds}');
                  // print('Selected Color IDs: ${controller.selectedColorIds}');
                  // print('Selected remarks IDs: ${controller.remarks}');
                  // print('Selected addons IDs: ${controller.addons}');
                  // print('Selected addons IDs: ${controller.addons}');
                  // final itemIdss = widget.selectedClothes.map((item) => int.tryParse(item['id'].toString()) ?? 0).toList();
                  // prepareRequestBody(controller, itemIdss);
                  // print(itemIdss);
                  print(controller.selectedAddonNames);
                  print(controller.selectedAddonPrices);
                  //itemIds[index];
                  //widget.selectedClothes['jj']

                  //Call the bookOrder function
                  await controller.bookOrder(
                      context: context,
                      storeId: storeId,
                      customerId: widget.userId,
                      itemIds: itemIds,
                      prices: prices,
                      quantities: quantities,
                      selcolor: controller.selectedColorIds,
                      selpattern: controller.selectedDefectIds,
                      selbrand: controller.selectedStainIds,
                      remarks: controller.remarks,
                      addonsname: controller.selectedAddonNames,
                      addonsprice: controller.selectedAddonPrices);
                  print(itemIds);

                  //print('Order added for user: ${widget.userId}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Add Order',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
