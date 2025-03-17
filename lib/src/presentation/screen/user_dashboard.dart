import 'package:fabspinrider/src/presentation/booking/screen/add_customer_screen.dart';
import 'package:fabspinrider/src/presentation/screen/clothes_search.dart';
import 'package:fabspinrider/src/presentation/widgets/image_picker_cropper.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class UserDashboardScreen extends StatefulWidget {
  final userId;
  final userName;

  const UserDashboardScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  List<dynamic> recentOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() => isLoading = true);

    final response = await http.get(
        Uri.parse('https://fabspin.org/api/customer-order/${widget.userId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recentOrders = data['data'].toList();
      });
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit_customer') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCustomerScreen(
                      calledFrom: "edit-customer",
                      customerId: widget.userId,
                    ),
                  ),
                );

                if (result == true) {
                  // If data was updated
                  fetchUserData(); // Fetch latest data
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit_customer',
                  child: Text('Edit Customer'),
                ),
              ];
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchUserData, // Allow pull-to-refresh
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _buildHeader(),
                    const SizedBox(height: 18),
                    recentOrders.isEmpty
                        ? const Expanded(
                            child: Center(
                              child: Text(
                                'No recent orders found',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        : _buildRecentOrdersList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.userName,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClothesSearch(
                  userId: widget.userId,
                  userName: widget.userName,
                ),
              ),
            );
          },
          child: const Text('Book per pieces'),
        ),
      ],
    );
  }

  Widget _buildRecentOrdersList() {
    return Expanded(
      child: ListView.builder(
        itemCount: recentOrders.length,
        itemBuilder: (context, index) {
          final order = recentOrders[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            shadowColor: Colors.grey.shade300,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text('Booking Code: ${order['booking_code']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(order['booking_date']))}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  Text(
                    'Total Amount: ₹${order['order_total_after_tax']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Text(
                    'Amount Due: ₹${order['order_total_amount_due']}',
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.blue),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return ImagePickerCropper(
                        imagePath: (String? path) {
                          if (path != null) {
                            print('Selected image path: $path');
                            // Call your uploadImage function if needed
                          }
                        },
                        deleteImage: () {},
                        showDelete: false,
                        isCropperRequired: true,
                        removeDeleteOption: true,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
