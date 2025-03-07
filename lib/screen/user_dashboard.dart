import 'package:fabspinrider/screen/clothes_search.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class UserDashboardScreen extends StatefulWidget {
  final userId;
  final userName;

  const UserDashboardScreen(
      {Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
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
    final response = await http.get(
        Uri.parse('https://fabspin.org/api/customer-order/${widget.userId}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recentOrders = data['data'].toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recentOrders.isEmpty
              ? const Center(child: Text('No recent orders found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${widget.userName}",
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
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
                                          )));
                            },
                            child: const Text('Book per pieces'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Recent Orders:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: recentOrders.length,
                          itemBuilder: (context, index) {
                            final order = recentOrders[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              shadowColor: Colors.grey.shade300,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                    'Booking Code: ${order['booking_code']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Booking Date: ' +
                                          DateFormat('dd MMM yyyy, hh:mm a')
                                              .format(DateTime.parse(
                                                  order['booking_date'])),
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    Text(
                                      'Total Amount: ₹${order['order_total_after_tax']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87),
                                    ),
                                    Text(
                                      'Amount Due: ₹${order['order_total_amount_due']}',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
