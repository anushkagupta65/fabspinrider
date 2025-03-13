import 'package:fabspinrider/booking/controller/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingScreenHelpers {
  BookingController controller = Get.put(BookingController());

  static void showSearchDialog(BuildContext context, int clothIndex,
      BookingController controller, int id) {
    final TextEditingController searchController = TextEditingController();

    controller.initializeClothSelections(clothIndex);

    Get.dialog(
      AlertDialog(
        title: const Text('Search Addons'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Enter addon name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                controller.fetchAddons(query);
              },
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.addons.isEmpty) {
                return const Text('No addons found');
              }
              return SizedBox(
                width: double.maxFinite,
                height: 200,
                child: ListView.builder(
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
                          controller.addAddonToCloth(id, addon['name'], price);
                          controller.finalizeSelections();
                          Navigator.pop(context);
                        } else {
                          controller.removeAddonFromCloth(
                              id, addon['name'], price);
                          Navigator.pop(context);
                        }
                        controller.refreshSelections();
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
              Get.back();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void showRemarksDialog(
      BuildContext context, int index, BookingController controller) {
    final TextEditingController remarksController = TextEditingController();
    controller.initializeRemarks(index);

    Get.dialog(
      AlertDialog(
        title: const Text('Enter Remarks'),
        content: TextField(
          controller: remarksController,
          decoration: const InputDecoration(
            labelText: 'Remarks',
            border: OutlineInputBorder(),
            hintText: 'Enter your remarks here',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              String remarks = remarksController.text.trim();
              if (remarks.isNotEmpty) {
                controller.remarks[index] = remarks;
                controller.remarks.refresh();
                Get.back();
              } else {
                Get.snackbar('Error', 'Please enter some remarks');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  static void showStainDialog(BuildContext context, int clothIndex,
      BookingController controller) async {
    await controller.fetchStain();

    // Ensure selections are initialized for this cloth
    controller.initializeClothSelectionsstains(clothIndex);

    Get.dialog(
      AlertDialog(
        title: const Text('Stains'),
        content: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.brands.isEmpty) {
            return const Text('No stains available.');
          }
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.brands.length,
              itemBuilder: (context, index) {
                final brand = controller.brands[index];

                return RadioListTile<int>(
                  value: brand['id'],
                  groupValue: controller.selectedStainIds[clothIndex],
                  onChanged: (value) {
                    controller.selectedStainIds[clothIndex] = value!;
                    controller.selectedStainIds.refresh();
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
              Get.back();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void showDefectsDialog(BuildContext context, int clothIndex,
      BookingController controller) async {
    await controller.fetchDefects();

    controller.initializeDefectSelections(clothIndex);

    Get.dialog(
      AlertDialog(
        title: const Text('Defects'),
        content: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.defects.isEmpty) {
            return const Text('No defects available.');
          }
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.defects.length,
              itemBuilder: (context, index) {
                final defect = controller.defects[index];

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
              Get.back();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void showColorsDialog(BuildContext context, int clothIndex,
      BookingController controller) async {
    await controller.fetchColors();
    controller.initializeColorSelections(clothIndex);

    Get.dialog(
      AlertDialog(
        title: const Text('Colors'),
        content: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.colors.isEmpty) {
            return const Text('No colors available.');
          }
          return SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.colors.length,
              itemBuilder: (context, index) {
                final color = controller.colors[index];

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
              Get.back();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static void initializePriceFields(List<TextEditingController> controllers,
      List<num> currentPrices, List<int> counters) {
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].text = (currentPrices[i] * counters[i]).toString();
    }
  }

  // static void updatePrice(int index, List<TextEditingController> controllers,
  //     List<num> currentPrices, List<int> counters) {
  //   controllers[index].text =
  //       (currentPrices[index] * counters[index]).toString();
  // }

  static void onPriceChanged(int index, String value, List<num> currentPrices,
      List<int> counters, Function setStateCallback) {
    try {
      String sanitizedValue = value.replaceAll(',', '');
      double newTotalPrice = double.tryParse(sanitizedValue) ?? 0.0;
      if (newTotalPrice > 0 && counters[index] > 0) {
        setStateCallback(() {
          currentPrices[index] = newTotalPrice / counters[index];
        });
      }
    } catch (e) {
      debugPrint("Error : $e");
    }
  }
}
