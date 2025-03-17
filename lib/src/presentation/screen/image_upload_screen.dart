import 'package:fabspinrider/src/presentation/booking/screen/home_search.dart';
import 'package:fabspinrider/src/presentation/widgets/image_picker_cropper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ClothItem {
  final id;
  final String subClothsName;
  final String barcode;
  final String serviceName;
  final List<String>? bookingImages;
  final List<String>? stainImages;
  final List<String>? defectImages;

  ClothItem({
    required this.id,
    required this.subClothsName,
    required this.barcode,
    required this.serviceName,
    this.bookingImages,
    this.stainImages,
    this.defectImages,
  });

  factory ClothItem.fromJson(Map<String, dynamic> json) {
    return ClothItem(
      id: json['id'],
      subClothsName: json['sub_cloths_name'],
      barcode: json['barcode'],
      serviceName: json['service_name'],
      bookingImages:
          json['booking_image'] != null ? [json['booking_image']] : null,
      stainImages: json['stain_images'] != null ? [json['stain_images']] : null,
      defectImages:
          json['defect_images'] != null ? [json['defect_images']] : null,
    );
  }
}

class BarcodeScreen extends StatefulWidget {
  final String bookingId;

  const BarcodeScreen({Key? key, required this.bookingId}) : super(key: key);

  @override
  _BarcodeScreenState createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  late Future<List<ClothItem>> _clothItems;
  Map<String, Map<String, List<String>>> localImages = {};

  @override
  void initState() {
    super.initState();
    _clothItems = fetchClothItems();
  }

  Future<List<ClothItem>> fetchClothItems() async {
    final response = await http.get(
      Uri.parse('https://fabspin.org/api/barcode-image/${widget.bookingId}'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<ClothItem> items = (data['data'] as List)
          .map((item) => ClothItem.fromJson(item))
          .toList();

      for (var item in items) {
        localImages[item.id.toString()] = {
          'garment': item.bookingImages ?? [],
          'stain': item.stainImages ?? [],
          'defect': item.defectImages ?? [],
        };
      }
      return items;
    } else {
      throw Exception('Failed to load cloth items');
    }
  }

  // Function to upload image to API
  Future<void> uploadImage(
      String clothId, String type, String imagePath) async {
    try {
      var headers = {'Accept': 'application/json'};
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://fabspin.org/api/upload-barcode-image'));

      // Add barcode_id (assuming clothId is the barcode_id, adjust if needed)
      request.fields.addAll({'barcode_id': clothId});

      // Add the image based on the type
      if (type == 'garment') {
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
      } else if (type == 'stain') {
        request.files
            .add(await http.MultipartFile.fromPath('stain_images', imagePath));
      } else if (type == 'defect') {
        request.files
            .add(await http.MultipartFile.fromPath('defect_images', imagePath));
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        Get.snackbar(
          "Success",
          'Image uploaded successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print('Failed to upload image: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void addImage(String clothId, String type, String imagePath) {
    setState(() {
      localImages[clothId]![type]!.add(imagePath);
    });
    uploadImage(clothId, type, imagePath);
  }

  Widget buildImageSection(List<String>? images, String clothId, String type) {
    final currentImages = localImages[clothId]![type]!;

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...currentImages.map((imageUrl) => SizedBox(
                  width: 100,
                  height: 100,
                  child: imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        )
                      : Image.file(
                          File(imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                )),
            if (currentImages.isEmpty)
              Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return ImagePickerCropper(
                            imagePath: (String? path) {
                              if (path != null) {
                                addImage(clothId, type, path);
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
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(type.capitalizing()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloth Items'),
      ),
      body: Column(
        children: [
          // Scrollable list of cards
          Expanded(
            child: FutureBuilder<List<ClothItem>>(
              future: _clothItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No items found'));
                }

                final items = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.subClothsName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Barcode: ${item.barcode}'),
                            const SizedBox(height: 8),
                            Text('Services: ${item.serviceName}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: buildImageSection(item.bookingImages,
                                      item.id.toString(), 'garment'),
                                ),
                                Expanded(
                                  child: buildImageSection(item.stainImages,
                                      item.id.toString(), 'stain'),
                                ),
                                Expanded(
                                  child: buildImageSection(item.defectImages,
                                      item.id.toString(), 'defect'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Fixed button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _confirmButton(context),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizing() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

Widget _confirmButton(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeSearch()),
        (Route<dynamic> route) => false,
      );
    },
    child: Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black,
      ),
      child: const Center(
        child: Text(
          "Back to Home",
          style: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}
