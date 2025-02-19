import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controller/controller.dart';
import '../model/order.dart';

class AddClothes extends StatelessWidget {
  final PickupDrop order;
  final RiderController controller = Get.put(RiderController());

  AddClothes({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Adjust Clothes Count"),
      content: Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Text("Total Clothes: ${controller.totalClothes}", style: TextStyle(fontSize: 24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: controller.decrementClothes,
              ),
              Text(controller.totalClothes.toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: controller.incrementClothes,
              ),
            ],
          ),
        ],
      )),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        SizedBox(width: 30,),
        ElevatedButton(
          onPressed: () async {
            await controller.updatePickup(order.id.toString());
            controller.totalClothes = 0.obs;// Call the API to update
            Navigator.pop(context); // Close the dialog
          },
          child: Text("Update"),
        ),
      ],
    );
  }
}
