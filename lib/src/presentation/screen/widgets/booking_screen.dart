import 'dart:io';
import 'package:fabspinrider/src/controller/booking_controller.dart';
import 'package:fabspinrider/src/presentation/screen/widgets/booking_screen_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedClothes;
  final String userId;
  final userName;

  const BookingScreen(
      {super.key,
      required this.selectedClothes,
      required this.userId,
      required this.userName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late List<int> counters;
  late List<TextEditingController> controllers;
  late List<num> currentPrices;
  BookingController controller = Get.put(BookingController());
  String selectedids = '0';

  bool sameDayDelivery = false;
  bool nextDayDelivery = false;

  @override
  void initState() {
    super.initState();
    debugPrint(
        "\n\n ========= These are selected clothes recieved ${widget.selectedClothes} ========= \n\n",
        wrapWidth: null);
    counters =
        List<int>.filled(widget.selectedClothes.length, 1, growable: true);
    controllers = List<TextEditingController>.generate(
      widget.selectedClothes.length,
      (index) {
        final price =
            _parsePrice(widget.selectedClothes[index]['standerd_price']);
        return TextEditingController(text: price.toString());
      },
      growable: true,
    );
    currentPrices = widget.selectedClothes
        .map((item) => _parsePrice(item['standerd_price']))
        .toList(growable: true);
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

  void prepareRequestBody(BookingController controller, List<int> itemIds) {
    final Map<String, dynamic> requestBody = {
      "addonname": {},
      "addonprice": {},
      "images": {},
    };

    for (final clothId in itemIds) {
      if (controller.selectedAddonNames.containsKey(clothId)) {
        requestBody["addonname"][clothId.toString()] =
            controller.selectedAddonNames[clothId];
        requestBody["addonprice"][clothId.toString()] =
            controller.selectedAddonPrices[clothId];
      }

      if (controller.imagePaths.containsKey(clothId) &&
          controller.imagePaths[clothId]!.isNotEmpty) {
        requestBody["images"][clothId.toString()] =
            controller.imagePaths[clothId];
      }
    }

    debugPrint("Request Body: $requestBody");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Selected Clothes for ${widget.userName}'),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "${item['cloth_name']}",
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          final duplicateItem =
                                              Map<String, dynamic>.from(item);
                                          // Optionally, update the id if necessary
                                          // duplicateItem['id'] = generateNewId();

                                          widget.selectedClothes
                                              .insert(index + 1, duplicateItem);
                                          counters.insert(index + 1, 1);
                                          controllers.insert(
                                            index + 1,
                                            TextEditingController(
                                                text: _parsePrice(
                                                        widget.selectedClothes[
                                                                index]
                                                            ['standerd_price'])
                                                    .toString()),
                                          );
                                          currentPrices.insert(
                                              index + 1,
                                              _parsePrice(
                                                  widget.selectedClothes[index]
                                                      ['standerd_price']));
                                        });
                                      },
                                      icon: const CircleAvatar(
                                        backgroundColor: Colors.black87,
                                        radius: 14,
                                        child: Icon(
                                          Icons.content_copy,
                                          color: Colors.white,
                                          size: 17,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          widget.selectedClothes
                                              .removeAt(index);
                                        });
                                      },
                                      icon: const CircleAvatar(
                                        backgroundColor: Colors.black87,
                                        radius: 14,
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "Price per item: ₹${currentPrices[index].floor()}",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                            const SizedBox(height: 22),
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
                                            // BookingScreenHelpers.updatePrice(
                                            //     index,
                                            //     controllers,
                                            //     currentPrices,
                                            //     counters);
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

                                          // BookingScreenHelpers.updatePrice(
                                          //     index,
                                          //     controllers,
                                          //     currentPrices,
                                          //     counters);
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
                                  onTap: counters[index] > 1
                                      ? () {
                                          Get.snackbar(
                                            "Error",
                                            "This option is disabled when quantity is more than 1",
                                          );
                                          // ScaffoldMessenger.of(context)
                                          //     .showSnackBar(
                                          //   const SnackBar(
                                          //     content: Text(
                                          //         "This option is disabled when quantity > 1"),
                                          //     duration: Duration(seconds: 2),
                                          //   ),
                                          // );
                                        }
                                      : () {
                                          BookingScreenHelpers.showStainDialog(
                                              context, index, controller);
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: counters[index] > 1
                                          ? Colors.grey.withValues(alpha: 0.12)
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Obx(() {
                                        if (index >=
                                            controller
                                                .selectedStainIds.length) {
                                          return Text(
                                            'Stain',
                                            style: counters[index] > 1
                                                ? const TextStyle(
                                                    color: Colors.grey)
                                                : const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                          );
                                        }
                                        final selectedStainId =
                                            controller.selectedStainIds[index];
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
                                          style: counters[index] > 1
                                              ? const TextStyle(
                                                  color: Colors.grey)
                                              : const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          textAlign: TextAlign.center,
                                        );
                                      }),
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
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ));
                                          }

                                          if (index >=
                                              controller
                                                  .selectedColorIds.length) {
                                            return const Text('Color',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ));
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
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: counters[index] > 1
                                      ? () {
                                          Get.snackbar(
                                            "Error",
                                            "This option is disabled when quantity is more than 1",
                                          );
                                          // ScaffoldMessenger.of(context)
                                          //     .showSnackBar(
                                          //   const SnackBar(
                                          //     content: Text(
                                          //         "This option is disabled when quantity > 1"),
                                          //     duration: Duration(seconds: 2),
                                          //   ),
                                          // );
                                        }
                                      : () {
                                          BookingScreenHelpers
                                              .showDefectsDialog(
                                                  context, index, controller);
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: counters[index] > 1
                                          ? Colors.grey.withValues(alpha: 0.12)
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Obx(() {
                                        if (index >=
                                            controller
                                                .selectedDefectIds.length) {
                                          return Text(
                                            'Defects',
                                            style: counters[index] > 1
                                                ? const TextStyle(
                                                    color: Colors.grey)
                                                : const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                          );
                                        }
                                        final selectedDefectId =
                                            controller.selectedDefectIds[index];
                                        final selectedDefect =
                                            controller.defects.firstWhere(
                                          (defect) =>
                                              defect['id'] == selectedDefectId,
                                          orElse: () => <String, dynamic>{},
                                        );

                                        return Text(
                                          selectedDefect.containsKey('remarks')
                                              ? '${selectedDefect['remarks']}'
                                              : 'Defects',
                                          style: counters[index] > 1
                                              ? const TextStyle(
                                                  color: Colors.grey)
                                              : const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          textAlign: TextAlign.center,
                                        );
                                      }),
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
                                      child: Text(
                                        'Remarks',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                      child: Text(
                                        'Addons',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _deliveryOptions(),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  final storeId = prefs.getInt('StoreId');

                  if (storeId == null) {
                    debugPrint("Store ID is null");
                    return;
                  }

                  final itemIds = widget.selectedClothes
                      .map((item) {
                        final id = item['id'];
                        debugPrint('Mapped ID: $id');

                        if (id is int) {
                          return id;
                        } else if (id is String) {
                          final parsedId = int.tryParse(id);
                          if (parsedId != null) {
                            return parsedId;
                          } else {
                            debugPrint('Invalid ID string: $id');
                            return null;
                          }
                        } else {
                          debugPrint('Unknown ID type: $id');
                          return null;
                        }
                      })
                      .where((id) => id != null)
                      .toList()
                      .cast<int>();

                  debugPrint('Final Item IDs: $itemIds');

                  final prices = List.generate(currentPrices.length, (index) {
                    return (currentPrices[index] * counters[index]).toDouble();
                  });

                  final quantities = counters;

                  debugPrint(
                      "Selected Add-ons: ${controller.selectedAddonNames}");
                  debugPrint(
                      "Selected Add-on Prices: ${controller.selectedAddonPrices}");
                  debugPrint("Selected images: ${controller.imagePaths}");
                  debugPrint("Final Prices (Total per item): $prices");

                  Map<int, List<File>> convertPathsToFiles(
                      Map<int, List<String>> imagePaths) {
                    return imagePaths.map(
                      (key, value) => MapEntry(
                        key,
                        value.map((path) => File(path)).toList(),
                      ),
                    );
                  }

                  int? deliveryOption;
                  if (sameDayDelivery) {
                    deliveryOption = 1;
                  } else if (nextDayDelivery) {
                    deliveryOption = 2;
                  } else {
                    deliveryOption = null;
                  }

                  await controller
                      .bookOrder(
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
                    itemImages: convertPathsToFiles(controller.imagePaths),
                    sameOrNextDay: deliveryOption,
                  )
                      .then((_) {
                    debugPrint(
                        "Order placed successfully with item prices: $prices");
                  });
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
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveryOptions() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text("Same Day Delivery"),
          value: sameDayDelivery,
          onChanged: (value) {
            setState(() {
              if (sameDayDelivery) {
                sameDayDelivery = false;
              } else {
                sameDayDelivery = true;
                nextDayDelivery = false;
              }
            });
          },
        ),
        CheckboxListTile(
          title: const Text("Next Day Delivery"),
          value: nextDayDelivery,
          onChanged: (value) {
            setState(() {
              if (nextDayDelivery) {
                nextDayDelivery = false;
              } else {
                nextDayDelivery = true;
                sameDayDelivery = false;
              }
            });
          },
        ),
      ],
    );
  }
}
