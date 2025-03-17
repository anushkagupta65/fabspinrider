import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/rider_controller.dart';
import '../../model/order.dart';

class AddClothes extends StatelessWidget {
  final PickupDrop order;
  final RiderController controller = Get.put(RiderController());

  AddClothes({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Adjust Clothes Count"),
      content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: controller.decrementClothes,
                  ),
                  Text(controller.totalClothes.toString()),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: controller.incrementClothes,
                  ),
                ],
              ),
            ],
          )),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        const SizedBox(
          width: 30,
        ),
        ElevatedButton(
          onPressed: () async {
            await controller.updatePickup(order.id.toString());
            controller.totalClothes = 0.obs;
            Navigator.pop(context);
          },
          child: const Text("Update"),
        ),
      ],
    );
  }
}
