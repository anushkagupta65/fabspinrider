import 'package:fabspinrider/screen/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/controller.dart';

class OrderHistoryScreen extends StatefulWidget {
  static const String routeName = '/order-history-screen';
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final RiderController controller = Get.put(RiderController());

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateSelectedTab('Picked Up');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Delivery History',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(
        () {
          final pickedUpOrders = controller.filteredOrders;

          return pickedUpOrders.isEmpty
              ? const Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: pickedUpOrders.length,
                  itemBuilder: (context, index) {
                    var order = pickedUpOrders[index];
                    return OrderCard(
                      order: order,
                      pickUpOrder: () {},
                    );
                  },
                );
        },
      ),
    );
  }
}
