import 'dart:io';
import 'package:fabspinrider/src/presentation/screen/confirm_store_booking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../presentation/booking/screen/home_search.dart';

class BookingController extends GetxController {
  var filteredItems = <Map<String, String>>[].obs;
  var clothesSearched = <Map<String, String>>[].obs;
  var isLoading = false.obs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  var userid = 0.obs;
  var brands = <Map<String, dynamic>>[].obs;
  var selectedStainIds = <int>[].obs;
  var selectedAddons = <int, List<int>>{}.obs;
  var colors = <Map<String, dynamic>>[].obs;
  var defects = <Map<String, dynamic>>[].obs;
  var addons = <Map<String, dynamic>>[].obs;
  var remarks = <String>[].obs;
  var selectedAddonNames = <int, List<String>>{}.obs;
  var selectedAddonPrices = <int, List<int>>{}.obs;
  var selectedDefectIds = <int>[].obs;
  var selectedColorIds = <int>[].obs;
  var imagePaths = <int, List<String>>{}.obs;

  void initializeClothSelections(int clothIndex) {
    if (!selectedAddonNames.containsKey(clothIndex)) {
      selectedAddonNames[clothIndex] = [];
    }
    if (!selectedAddonPrices.containsKey(clothIndex)) {
      selectedAddonPrices[clothIndex] = [];
    }
  }

  void addAddonToCloth(int clothIndex, String name, int price) {
    if (!selectedAddonNames.containsKey(clothIndex)) {
      selectedAddonNames[clothIndex] = [];
    }
    if (!selectedAddonPrices.containsKey(clothIndex)) {
      selectedAddonPrices[clothIndex] = [];
    }

    if (!selectedAddonNames[clothIndex]!.contains(name)) {
      selectedAddonNames[clothIndex]!.add(name);
      selectedAddonPrices[clothIndex]!.add(price);
      debugPrint('Updated selectedAddonNames: $selectedAddonNames');
      debugPrint('Updated selectedAddonPrices: $selectedAddonPrices');
    }
  }

  void removeEmptySelections() {
    selectedAddonNames.removeWhere((key, value) => value.isEmpty);
    selectedAddonPrices.removeWhere((key, value) => value.isEmpty);
  }

  void finalizeSelections() {
    removeEmptySelections();
    debugPrint('Final selections:');
    debugPrint('Names: $selectedAddonNames');
    debugPrint('Prices: $selectedAddonPrices');
  }

  void removeAddonFromCloth(int clothIndex, String name, int price) {
    initializeClothSelections(clothIndex);
    final nameIndex = selectedAddonNames[clothIndex]!.indexOf(name);
    if (nameIndex != -1) {
      selectedAddonNames[clothIndex]!.removeAt(nameIndex);
      selectedAddonPrices[clothIndex]!.removeAt(nameIndex);
    }
  }

  void refreshSelections() {
    selectedAddonNames.refresh();
    selectedAddonPrices.refresh();
    imagePaths.refresh();
  }

  void initializeClothSelectionsstains(int clothIndex) {
    while (selectedStainIds.length <= clothIndex) {
      selectedStainIds.add(-1);
    }
  }

  void initializeDefectSelections(int clothIndex) {
    while (selectedDefectIds.length <= clothIndex) {
      selectedDefectIds.add(-1);
    }
  }

  void initializeColorSelections(int clothIndex) {
    while (selectedColorIds.length <= clothIndex) {
      selectedColorIds.add(-1);
    }
  }

  void initializeRemarks(int index) {
    while (remarks.length <= index) {
      remarks.add('');
    }
  }

  void addImagesToCloth(int clothId, List<String> newImagePaths) {
    if (!imagePaths.containsKey(clothId)) {
      imagePaths[clothId] = newImagePaths;
    } else {
      imagePaths[clothId]?.addAll(newImagePaths);
    }
    update();
  }

  void removeImageFromCloth(int clothId, {String? imagePathToRemove}) {
    if (!imagePaths.containsKey(clothId)) return;

    if (imagePathToRemove != null) {
      imagePaths[clothId]?.remove(imagePathToRemove);
    } else {
      // If no specific image is provided, remove all images for the clothId
      imagePaths.remove(clothId);
    }

    // Remove the clothId entry if no images remain
    if (imagePaths[clothId]?.isEmpty ?? true) {
      imagePaths.remove(clothId);
    }

    imagePaths.refresh(); // Ensure UI rebuilds
    update();
  }

  Future<void> fetchAddons(String query) async {
    isLoading(true);
    final prefs = await SharedPreferences.getInstance();
    userid.value = prefs.getInt('UserId') ?? 0;
    try {
      final response = await GetConnect()
          .get('https://fabspin.org/api/addons?store_id=$userid&query=$query');
      if (response.statusCode == 200 && response.body['success']) {
        addons.value = List<Map<String, dynamic>>.from(response.body['data']);
      } else {
        addons.clear();
        Get.snackbar('Error', 'Failed to fetch addons');
      }
    } catch (e) {
      addons.clear();
      Get.snackbar('Error', 'An error occurred');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchDefects() async {
    isLoading(true); // Set loading to true
    final prefs = await SharedPreferences.getInstance();
    userid.value = prefs.getInt('UserId') ?? 0;
    final url = 'https://fabspin.org/api/defects?store_id=$userid';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          defects.value = List<Map<String, dynamic>>.from(
              responseData['data']); // Store the data array
        } else {
          Get.snackbar('Error', 'Failed to fetch defects');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch defects');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
    } finally {
      isLoading(false); // Set loading to false
    }
  }

  Future<void> fetchStain() async {
    isLoading(true); // Set loading to true
    final prefs = await SharedPreferences.getInstance();
    userid.value = prefs.getInt('UserId') ?? 0;
    final url = 'https://fabspin.org/api/brands?store_id=$userid';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          brands.value = List<Map<String, dynamic>>.from(
              responseData['data']); // Store the data array
        } else {
          Get.snackbar('Error', 'Failed to fetch stains');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch stains');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
    } finally {
      isLoading(false); // Set loading to false
    }
  }

  Future<void> fetchColors() async {
    isLoading(true); // Set loading to true
    final prefs = await SharedPreferences.getInstance();
    userid.value = prefs.getInt('UserId') ?? 0;
    final url = 'https://fabspin.org/api/colors?store_id=$userid';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          colors.value = List<Map<String, dynamic>>.from(
              responseData['data']); // Store the data array
        } else {
          Get.snackbar('Error', 'Failed to fetch colors');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch colors');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
    } finally {
      isLoading(false); // Set loading to false
    }
  }

  Future<void> bookOrder({
    required BuildContext context,
    required int storeId,
    required String customerId,
    required List<int> itemIds,
    required List<double> prices,
    required List<int> quantities,
    required List<int> selcolor,
    required List<int> selpattern,
    required List<int> selbrand,
    required List<String> remarks,
    required Map<int, List<String>> addonsname,
    required Map<int, List<int>> addonsprice,
    required Map<int, List<File>> itemImages,
    int? sameOrNextDay,
  }) async {
    final String url = "https://fabspin.org/api/create-laundry";
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    };

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..fields.addAll({
        'store_id': storeId.toString(),
        'customer_id': customerId.toString(),
        'same_or_next_day': sameOrNextDay?.toString() ?? '',
      });

    // Add fields (unchanged)
    for (var i = 0; i < itemIds.length; i++) {
      request.fields['itemid[$i]'] = itemIds[i].toString();
      if (i < prices.length) request.fields['price[$i]'] = prices[i].toString();
      if (i < quantities.length) {
        request.fields['quant[$i]'] = quantities[i].toString();
      }
      if (i < selcolor.length) {
        request.fields['selcolor[$i]'] = selcolor[i].toString();
      }
      if (i < selpattern.length) {
        request.fields['selpattern[$i]'] = selpattern[i].toString();
      }
      if (i < selbrand.length) {
        request.fields['selbrand[$i]'] = selbrand[i].toString();
      }
      if (i < remarks.length) request.fields['selremarks[$i]'] = remarks[i];
    }
    addonsname.forEach((key, value) {
      for (var i = 0; i < value.length; i++) {
        request.fields['addonname[$key][$i]'] = value[i];
      }
    });
    addonsprice.forEach((key, value) {
      for (var i = 0; i < value.length; i++) {
        request.fields['addonprice[$key][$i]'] = value[i].toString();
      }
    });

    // Add images
    for (var i = 0; i < itemIds.length; i++) {
      final itemId = itemIds[i];
      // Check if images exist for this item
      final images = itemImages[i]; // Assuming itemImages is indexed by i
      print(
          'Processing itemId: $itemId with images: ${images?.map((img) => img.path).toList() ?? "none"}');

      if (images != null && images.isNotEmpty) {
        for (var j = 0; j < images.length; j++) {
          final image = images[j];
          print('Checking image $j for itemId $itemId: ${image.path}');

          if (image.existsSync()) {
            final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
            // Use explicit indexing to differentiate images (e.g., images[3751][0], images[3751][1])
            final fieldName = 'images[$itemId][$j]';
            final file = await http.MultipartFile.fromPath(
              fieldName,
              image.path,
              contentType: MediaType.parse(mimeType),
            );
            request.files.add(file);
            print('Added file: ${image.path} as $fieldName ($mimeType)');
          } else {
            print('File not found: ${image.path}');
          }
        }
      } else {
        print('No images for itemId: $itemId');
      }
    }

    try {
      print('Sending request with fields: ${request.fields}');
      print('Files: ${request.files.map((f) => f.filename).toList()}');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Status Code: ${response.statusCode}');
      print('Response: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(responseBody);
        Get.snackbar(
            "Success", "Order booked successfully: ${responseData['message']}");
        final bookingId = responseData['booking_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmStoreBooking(
              bookingId: bookingId,
              customerId: customerId,
              storeId: storeId,
            ),
          ),
        );
      } else {
        final errorData = jsonDecode(responseBody);
        Get.snackbar("Error",
            "Failed to book order: ${errorData['error'] ?? 'Unknown error'}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
      print("Error: $e");
    }
  }

  Future<void> searchClothes(String storeid, String query) async {
    final prefs = await SharedPreferences.getInstance();
    final storeid = prefs.getInt('StoreId') ?? 0;
    if (query.isEmpty) {
      clothesSearched.clear();
      return;
    }

    final url = Uri.parse('https://fabspin.org/api/search-keyword');
    try {
      final response = await http.post(url, body: {
        "store_id": storeid.toString(),
        "query": query,
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        debugPrint("Clothes search response: $responseData");

        if (responseData != null && responseData is List) {
          // Convert list of cloth_name to list of maps
          final results = responseData.map<Map<String, String>>((item) {
            if (item is Map && item.containsKey('cloth_name')) {
              return {
                "cloth_name": item['cloth_name'].toString(),
                "standerd_price": item['standerd_price'].toString(),
                "service_name": item['service_name'].toString(),
                "subtrade_name": item['subtrade_name'].toString(),
                "id": item['id'].toString(),
              };
            }
            return {"cloth_name": "Unknown"};
          }).toList();

          clothesSearched.assignAll(results);
        } else {
          debugPrint("No valid search results found.");
        }
      } else {
        debugPrint(
            "Failed to search clothes. Status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error during search: $e");
    }
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter email and password',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    final url = Uri.parse('https://fabspin.org/api/store-login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      if (response.statusCode == 200 && data['success'] == true) {
        // Save user info if needed (e.g., using shared_preferences)
        print(data['data']['store_id']);
        prefs.setInt('StoreId', data['data']['store_id']);
        prefs.setInt('UserId', data['data']['user_id']);
        userid.value = prefs.getInt('UserId') ?? 0;
        Get.snackbar('Success', data['message'],
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.to(() => HomeSearch()); // Navigate to HomeSearch
      } else {
        Get.snackbar('Error', data['message'] ?? 'Login failed',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      final prefs = await SharedPreferences.getInstance();
      userid.value = prefs.getInt('UserId') ?? 0;
      print('Retrieved UserId: ${userid.value}');
    }
  }

  // Function to fetch and filter items from API.
  Future<void> filterItems(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final storeId = prefs.getInt('StoreId');
    if (query.isEmpty) {
      filteredItems.clear();
      return;
    }

    try {
      isLoading.value = true;
      final url = Uri.parse(
          'https://fabspin.org/api/search-customers?store_id=$storeId&q=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Log the full response for debugging.

        if (data['results'] != null) {
          // Ensure safe type conversion from dynamic to Map<String, String>
          final results = List<Map<String, String>>.from(
            data['results'].map((result) => {
                  'name': result['name']?.toString() ?? 'Unknown',
                  'phone': result['mobile']?.toString() ?? 'No phone',
                  'address': result['address']?.toString() ?? 'No Address',
                  'id': result['id']?.toString() ?? 'No id',
                }),
          );
          filteredItems.assignAll(results);
        } else {
          print('No results found in the response');
          filteredItems.clear();
        }
      } else {
        print('Non-200 status code: ${response.statusCode}');
        filteredItems.clear();
      }
    } catch (e) {
      print('Error fetching search results: $e');
      filteredItems.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
