import 'package:fabspinrider/booking/controller/booking_controller.dart';
import 'package:fabspinrider/screen/widgets/booking_screen_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedClothes;
  final String userId;

  const BookingScreen(
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Card(
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${item['cloth_name']}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                                "Price per item: ₹${currentPrices[index].floor()}",
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
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
                                            BookingScreenHelpers.updatePrice(
                                                index,
                                                controllers,
                                                currentPrices,
                                                counters);
                                          });
                                        }
                                      },
                                      child: const Icon(Icons.remove,
                                          color: Colors.black),
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
                                          BookingScreenHelpers.updatePrice(
                                              index,
                                              controllers,
                                              currentPrices,
                                              counters);
                                        });
                                      },
                                      child: const Icon(Icons.add,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: controllers[index],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[\d,.]')),
                                    ],
                                    onChanged: (value) {
                                      BookingScreenHelpers.onPriceChanged(
                                          index,
                                          value,
                                          currentPrices,
                                          counters,
                                          setState);
                                    },
                                    decoration: const InputDecoration(
                                      labelText: "Total",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            GridView(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 5,
                                childAspectRatio: 1.9,
                              ),
                              shrinkWrap: true,
                              children: [
                                InkWell(
                                  onTap: () {
                                    BookingScreenHelpers.showStainDialog(
                                        context, index, controller);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Obx(
                                        () {
                                          if (index >=
                                              controller
                                                  .selectedStainIds.length) {
                                            return const Text('Stain',
                                                style: TextStyle(
                                                    color: Colors.black));
                                          }

                                          final selectedStainId = controller
                                              .selectedStainIds[index];
                                          final selectedStain =
                                              controller.brands.firstWhere(
                                            (brand) =>
                                                brand['id'] == selectedStainId,
                                            orElse: () => <String, dynamic>{},
                                          );

                                          return Text(
                                            selectedStain.containsKey('name')
                                                ? '${selectedStain['name']}'
                                                : 'Stain',
                                            style: const TextStyle(
                                                color: Colors.black),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    BookingScreenHelpers.showColorsDialog(
                                        context, index, controller);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Obx(
                                        () {
                                          if (controller.colors.isEmpty ||
                                              index >=
                                                  controller.colors.length) {
                                            return const Text('Color',
                                                style: TextStyle(
                                                    color: Colors.black));
                                          }

                                          if (index >=
                                              controller
                                                  .selectedColorIds.length) {
                                            return const Text('Color',
                                                style: TextStyle(
                                                    color: Colors.black));
                                          }

                                          final selectedColorId = controller
                                              .selectedColorIds[index];

                                          final selectedColor =
                                              controller.colors.firstWhere(
                                            (color) =>
                                                color['id'] == selectedColorId,
                                            orElse: () => <String, dynamic>{},
                                          );

                                          return Text(
                                            selectedColor.containsKey('name')
                                                ? '${selectedColor['name']}'
                                                : 'Color',
                                            style: const TextStyle(
                                                color: Colors.black),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    BookingScreenHelpers.showDefectsDialog(
                                        context, index, controller);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Obx(
                                        () {
                                          if (controller.defects.isEmpty ||
                                              index >=
                                                  controller.defects.length) {
                                            return const Text('Defects',
                                                style: TextStyle(
                                                    color: Colors.black));
                                          }

                                          if (index >=
                                              controller
                                                  .selectedDefectIds.length) {
                                            return const Text('Defects',
                                                style: TextStyle(
                                                    color: Colors.black));
                                          }

                                          final selectedDefectId = controller
                                              .selectedDefectIds[index];

                                          final selectedDefect =
                                              controller.defects.firstWhere(
                                            (defect) =>
                                                defect['id'] ==
                                                selectedDefectId,
                                            orElse: () => <String, dynamic>{},
                                          );

                                          return Text(
                                            selectedDefect
                                                    .containsKey('remarks')
                                                ? "${selectedDefect['remarks']}"
                                                : 'Defects',
                                            style: const TextStyle(
                                                color: Colors.black),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    BookingScreenHelpers.showRemarksDialog(
                                        context, index, controller);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text('Remarks'),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    BookingScreenHelpers.showSearchDialog(
                                        context,
                                        index,
                                        controller,
                                        int.tryParse(
                                                widget.selectedClothes[index]
                                                    ['id']) ??
                                            0);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text('Addons'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Obx(() {
                              if (index >= controller.remarks.length ||
                                  controller.remarks[index].isEmpty) {
                                return const SizedBox();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 10,
                                ),
                                child: Text(
                                  "Remarks: ${controller.remarks[index]}",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                              );
                            }),
                            Obx(() {
                              final itemId = int.tryParse(
                                      widget.selectedClothes[index]['id']) ??
                                  0;

                              if (!controller.selectedAddonNames
                                      .containsKey(itemId) ||
                                  controller
                                      .selectedAddonNames[itemId]!.isEmpty) {
                                return const SizedBox();
                              }

                              final selectedAddons = controller
                                  .selectedAddonNames[itemId]!
                                  .join(', ');

                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 10,
                                ),
                                child: Text(
                                  "Addons: $selectedAddons",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  final storeId = prefs.getInt('StoreId');

                  if (storeId == null) {
                    print("Store ID is null");
                    return;
                  }

                  // Extract item IDs, ensuring they are valid integers
                  final itemIds = widget.selectedClothes
                      .map((item) {
                        final id = item['id'];
                        print('Mapped ID: $id');

                        if (id is int) {
                          return id;
                        } else if (id is String) {
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
                      .cast<int>();

                  print('Final Item IDs: $itemIds');

                  final prices = List.generate(currentPrices.length, (index) {
                    return (currentPrices[index] * counters[index]).toDouble();
                  });

                  final quantities = counters;

                  print("Selected Add-ons: ${controller.selectedAddonNames}");
                  print(
                      "Selected Add-on Prices: ${controller.selectedAddonPrices}");
                  print("Final Prices (Total per item): $prices");

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
                    addonsprice: controller.selectedAddonPrices,
                  );

                  print("Order placed successfully with item prices: $prices");
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
