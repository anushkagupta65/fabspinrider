import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BarcodeSearchScreen extends StatefulWidget {
  const BarcodeSearchScreen({super.key});

  @override
  State<BarcodeSearchScreen> createState() => _BarcodeSearchScreenState();
}

class _BarcodeSearchScreenState extends State<BarcodeSearchScreen> {
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  TextEditingController barcodeController = TextEditingController();
  List<dynamic> barcodeData = [];

  Future<void> fetchData() async {
    var headers = {'Accept': 'application/json'};
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://fabspin.org/api/barcode-image-report'),
    );
    request.fields.addAll({
      'store_id': '3',
      'from_date': DateFormat('yyyy-MM-dd').format(fromDate),
      'to_date': DateFormat('yyyy-MM-dd').format(toDate),
      'barcode': barcodeController.text,
    });
    request.headers.addAll(headers);

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 200 && decodedResponse['success'] == true) {
        setState(() {
          barcodeData = decodedResponse['data'];
        });
      } else {
        Get.snackbar(
            'Error', decodedResponse['message'] ?? 'Failed to load data');
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? fromDate : toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
        fetchData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Search')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Search Barcode',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => fetchData(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: fetchData,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateSelector(
                    context, 'Created Date (From)', true, fromDate),
                _buildDateSelector(context, 'Created Date (To)', false, toDate),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: barcodeData.isEmpty
                  ? const Center(child: Text('No data available'))
                  : ListView.builder(
                      itemCount: barcodeData.length,
                      itemBuilder: (context, index) {
                        final item = barcodeData[index];
                        return _buildItemCard(item, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(
      BuildContext context, String label, bool isFromDate, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        GestureDetector(
          onTap: () => _selectDate(context, isFromDate),
          child: Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: TextStyle(fontSize: 16, color: Colors.blue.shade800),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(dynamic item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.grey.shade300,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              _buildInfoColumn(item),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey.shade800,
              ),
              const SizedBox(height: 10),
              _buildImageSection(
                title: "Cloth",
                imageKey: 'booking_image',
                onCamTap: () {},
                onGalTap: () {},
                onViewTap: () {},
                item: item,
              ),
              const SizedBox(height: 10),
              _buildImageSection(
                title: "Stain",
                imageKey: 'stain_images',
                onCamTap: () {},
                onGalTap: () {},
                onViewTap: () {},
                item: item,
              ),
              const SizedBox(height: 10),
              _buildImageSection(
                title: "Defect",
                imageKey: 'defect_images',
                onCamTap: () {},
                onGalTap: () {},
                onViewTap: () {},
                item: item,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(dynamic item) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order: ${item['booking_code'] ?? ''}'),
            Text(
              'Barcode: ${item['barcode'] ?? ''}',
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Date: ${_formatDate(item['created_at'], 'dd MMM')}'),
            Text(
              'Due Date: ${_formatDate(item['drop_date'], 'dd MMM, yy')}',
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Garment: ${item['sub_cloths_name'] ?? ''}',
            ),
            Text(
              'Service: ${item['servicename'] ?? ''}',
            ),
          ],
        )
      ],
    );
  }

  Widget _buildImageSection({
    required String title,
    required String imageKey,
    required VoidCallback onGalTap,
    required VoidCallback onCamTap,
    required VoidCallback onViewTap,
    required dynamic item,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 32),
          if (title == "Cloth" || title == "Stain") const SizedBox(width: 10),
          GestureDetector(
            onTap: onCamTap,
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 15,
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 32),
          GestureDetector(
            onTap: onGalTap,
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 15,
              child: const Icon(
                Icons.upload,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 32),
          item[imageKey] != null
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GestureDetector(
                    onTap: onViewTap,
                    child: Row(
                      children: [
                        Text(
                          'View',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: 36),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr, String format) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat(format).format(DateTime.parse(dateStr));
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
