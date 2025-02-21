import 'package:fabspinrider/map/googlemaps.dart';
import 'package:fabspinrider/model/order.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/controller.dart';
import '../../widgets/custom_textbutton.dart';
import '../../widgets/my_snack_bar.dart';

final scheme = _ColorScheme();

class _ColorScheme {
  final primary = Colors.blue;
}

class OrderCard extends StatefulWidget {
  final PickupDrop order;
  final VoidCallback pickUpOrder;
  final bool isHistoryView = false;

  const OrderCard({
    super.key,
    required this.order,
    required this.pickUpOrder,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isCommentSeeMore = false;
  RiderController controller = Get.put(RiderController());

  Future<void> call() async {
    debugPrint('customer mobile ${widget.order.customerMobile}');
    final Uri telUri = Uri(scheme: 'tel', path: widget.order.customerMobile);
    final status = await Permission.phone.request();

    if (status.isGranted) {
      try {
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        } else {
          throw 'Could not launch dialer';
        }
      } catch (e) {
        debugPrint('Error: $e');
      }
    } else {
      debugPrint('Phone permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(1, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ORDER ID',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    '#${widget.order.id}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Order ${widget.order.type}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.cyan,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: const NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ9rZ29GFZZ1IAe08uB4LTFhuh7qomZWUr6QA&s' //widget.order.shop.shopImage,
                      ),
                  backgroundColor: scheme.primary,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    widget.order.customerName,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_city_outlined,
                      color: Colors.cyan,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PICK UP ADDRESS',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.order.pickupAddress,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.home_work_outlined,
                      color: Colors.cyan,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVER ADDRESS',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.order.deliverAddress,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Date: ${widget.order.pickupDate}  Time: ${widget.order.pickupTime}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            (controller.selectedTab.value != 'Deny' &&
                    controller.selectedTab.value != 'New Orders' &&
                    controller.selectedTab.value != 'Picked Up')
                ? CustomTextButton(
                    text: 'CALL',
                    onPressed: () {
                      call();
                    },
                    isDisabled: false,
                  )
                : const SizedBox(),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (controller.selectedTab.value != 'Deny' &&
                        controller.selectedTab.value != 'Accepted' &&
                        controller.selectedTab.value != 'Picked Up')
                    ? CustomTextButton(
                        width: 130,
                        text: 'Deny',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Denial"),
                                content: const Text(
                                    "Are you sure you want to deny?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      controller.denyOrder(
                                          widget.order.id, 1.toString());
                                      openSnackbar(context, 'Order Denied',
                                          Colors.black);
                                    },
                                    child: const Text("Deny",
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        isDisabled: controller.selectedTab.value == 'Picked Up'
                            ? true
                            : false,
                      )
                    : controller.selectedTab.value == 'Accepted'
                        ? CustomTextButton(
                            width: 130,
                            text: 'Maps',
                            onPressed: () {
                              startNavigation(widget.order);
                            },
                            isDisabled: false,
                          )
                        : const SizedBox(),
                (controller.selectedTab.value != 'Deny' &&
                        controller.selectedTab.value != 'Picked Up')
                    ? CustomTextButton(
                        width: 130,
                        text: controller.selectedTab.value == 'Accepted'
                            ? 'Add Clothes'
                            : 'Accept',
                        onPressed: widget.pickUpOrder,
                        isDisabled: controller.selectedTab.value == 'Picked Up'
                            ? true
                            : false,
                      )
                    : const SizedBox(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
