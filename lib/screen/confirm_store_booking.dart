import 'dart:convert';
import 'package:fabspinrider/booking/screen/home_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ConfirmStoreBooking extends StatefulWidget {
  final bookingId;
  final customerId;
  final storeId;

  const ConfirmStoreBooking(
      {super.key, this.bookingId, this.customerId, this.storeId});

  @override
  State<ConfirmStoreBooking> createState() => _ConfirmStoreBookingState();
}

class _ConfirmStoreBookingState extends State<ConfirmStoreBooking> {
  var bookingList = <Map<String, dynamic>>[];
  var customerName = '';
  var customerAddress = '';
  bool isLoading = true;
  int totalGarments = 0;
  int totalAddons = 0;

  Future<void> confirmLaundry() async {
    final url =
        "https://fabspin.org/api/confirm-laundry-page/${widget.bookingId}/${widget.customerId}";
    final finalUrl = Uri.parse(url);

    try {
      final response = await http.post(finalUrl, body: {
        "store_id": widget.storeId.toString(),
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['bookings'] != null &&
            responseData['bookings'] is List) {
          setState(() {
            bookingList =
                List<Map<String, dynamic>>.from(responseData['bookings']);
            customerName = responseData['customer']['name'];
            customerAddress = responseData['address']['address'];
            totalGarments = bookingList.fold(
                0,
                (sum, item) =>
                    sum + ((item['number_of_garment'] ?? 0) as num).toInt());
            totalAddons = responseData['totalAddonPrice'];

            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> parsePhpSerializedArray(String serialized) {
    final regex = RegExp(r's:\d+:"(.*?)";');
    final matches = regex.allMatches(serialized);
    return matches.map((match) => match.group(1)!).toList();
  }

  @override
  void initState() {
    super.initState();
    confirmLaundry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Booking")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingList.isEmpty
              ? const Center(child: Text("No bookings available"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: bookingList.length,
                          itemBuilder: (context, index) {
                            final bookingItem = bookingList[index];
                            final deserializedList = parsePhpSerializedArray(
                                bookingItem['garments']);

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${bookingItem['subtradename']} - ${bookingItem['clothname']}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Divider(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: List.generate(
                                        deserializedList.length,
                                        (i) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          child: Text(
                                              "${i + 1}: ${deserializedList[i]}",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54)),
                                        ),
                                      ),
                                    ),
                                    if (bookingItem['brandname'] != null)
                                      _infoText(
                                          "Color", bookingItem['brandname']),
                                    if (bookingItem['colorname'] != null)
                                      _infoText(
                                          "Color", bookingItem['colorname']),
                                    if (bookingItem['defectname'] != null)
                                      _infoText(
                                          "Defects", bookingItem['defectname']),
                                    if (bookingItem['remarks'] != null)
                                      _infoText(
                                          "Remarks", bookingItem['remarks']),
                                    if (bookingItem['addonname'] != null &&
                                        bookingItem['addonprice'] != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: List.generate(
                                          bookingItem['addonname'].length,
                                          (i) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: Text(
                                              "Addon: ${bookingItem['addonname'][i]} - ₹${bookingItem['addonprice'][i]}",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87),
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Quantity: ${bookingItem['quantity']} - Pcs: ${deserializedList.length}",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "Amount: ₹${bookingItem['price']}",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        _summaryCard(),
                        const SizedBox(height: 15),
                        _confirmButton()
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text("$label: $value",
          style: const TextStyle(fontSize: 14, color: Colors.black87)),
    );
  }

  Widget _summaryCard() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Booking Code: ${bookingList[0]['booking_code']}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Customer Name: $customerName"),
          Text("Customer Address: $customerAddress"),
          const Divider(),
          _summaryRow("Quantity", "${bookingList.length}"),
          _summaryRow("Pieces", "$totalGarments"),
          _summaryRow("Total", "₹${bookingList[0]['order_total_before_tax']}"),
          _summaryRow("Addons Total", "₹$totalAddons"),
          _summaryRow("Discount", "₹${bookingList[0]['discount'] ?? 0}"),
          _summaryRow("CGST (9%)", "₹${bookingList[0]['cgst'] ?? 0}"),
          _summaryRow("SGST (9%)", "₹${bookingList[0]['sgst'] ?? 0}"),
          _summaryRow("Total After Tax",
              "₹${bookingList[0]['order_total_after_tax'] ?? 0}"),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value)
        ],
      ),
    );
  }

  Widget _confirmButton() {
    return InkWell(
      onTap: () => Get.offAll(HomeSearch()),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.black),
        child: const Center(
            child: Text("Confirm", style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
