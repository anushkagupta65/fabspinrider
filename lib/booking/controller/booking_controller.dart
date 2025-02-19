import 'package:fabspinrider/screen/confirm_store_booking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../screen/home_search.dart';

class BookingController extends GetxController {
  // Correct type for filteredItems to store maps with name and phone.
  var filteredItems = <Map<String, String>>[].obs;
  var clothesSearched = <Map<String, String>>[].obs;
  var isLoading = false.obs; // Observable to track loading state.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  var userid = 0.obs; // Observable integer
  var brands = <Map<String, dynamic>>[].obs;
  var selectedStainIds = <int>[].obs; // A list of integers for storing one selected ID per cloth
  var selectedAddons = <int, List<int>>{}.obs;

  // Change to RxList<List<int>> for multiple cloth selections
  var colors = <Map<String, dynamic>>[].obs;
  var defects = <Map<String, dynamic>>[].obs;
  var addons = <Map<String, dynamic>>[].obs;
  var remarks = <String>[].obs;
  // var brands = <Map<String, dynamic>>[].obs; // For stains
  // var defects = <Map<String, dynamic>>[].obs; // For defects
  // var colors = <Map<String, dynamic>>[].obs; // For colors
  var selectedAddonNames = <int, List<String>>{}.obs;
  var selectedAddonPrices = <int, List<int>>{}.obs;
  //var selectedStainIds = <int>[].obs; // Selected stain IDs
  var selectedDefectIds = <int>[].obs; // Selected defect IDs
  var selectedColorIds = <int>[].obs; // Selected color IDs


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
      print('Updated selectedAddonNames: $selectedAddonNames');
      print('Updated selectedAddonPrices: $selectedAddonPrices');
    }
  }

  void removeEmptySelections() {
    selectedAddonNames.removeWhere((key, value) => value.isEmpty);
    selectedAddonPrices.removeWhere((key, value) => value.isEmpty);
  }

// Call this after selection
  void finalizeSelections() {
    removeEmptySelections();
    print('Final selections:');
    print('Names: $selectedAddonNames');
    print('Prices: $selectedAddonPrices');
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
  }



  // void addAddonToCloth(int clothIndex, int addonId) {
  //   initializeClothSelections(clothIndex);
  //   if (!selectedAddons[clothIndex]!.contains(addonId)) {
  //     selectedAddons[clothIndex]!.add(addonId);
  //   }
  // }
  //
  // // Remove an addon from a specific cloth index
  // void removeAddonFromCloth(int clothIndex, int addonId) {
  //   initializeClothSelections(clothIndex);
  //   selectedAddons[clothIndex]!.remove(addonId);
  // }
  //
  //
  void initializeClothSelectionsstains(int clothIndex) {
    // Ensure the list is initialized for the specific cloth index
    while (selectedStainIds.length <= clothIndex) {
      selectedStainIds.add(-1); // Initialize with -1 (indicating no selection)
    }
  }

  void initializeDefectSelections(int clothIndex) {
    while (selectedDefectIds.length <= clothIndex) {
      selectedDefectIds.add(-1); // Initialize with -1 (indicating no defect selected)
    }
  }

  void initializeColorSelections(int clothIndex) {
    while (selectedColorIds.length <= clothIndex) {
      selectedColorIds.add(-1); // Initialize with -1 (indicating no color selected)
    }
  }

  // Observable to store remarks for each index


// Function to ensure the list is initialized for the given index
  void initializeRemarks(int index) {
    while (remarks.length <= index) {
      remarks.add(''); // Initialize with an empty string
    }
  }





  // Reset stain selections for a specific cloth
  // void resetClothSelections(int clothIndex) {
  //   selectedStainIds[clothIndex].clear();
  // }

  Future<void> fetchAddons(String query) async {
    isLoading(true);
    final prefs = await SharedPreferences.getInstance();
    userid.value = prefs.getInt('UserId') ?? 0;
    try {
      final response = await GetConnect().get(
          'https://fabspin.org/api/addons?store_id=$userid&query=$query');
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


  //final RxBool isLoading = false.obs;


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
          defects.value = List<Map<String, dynamic>>.from(responseData['data']); // Store the data array
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
          brands.value = List<Map<String, dynamic>>.from(responseData['data']); // Store the data array
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
          colors.value = List<Map<String, dynamic>>.from(responseData['data']); // Store the data array
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
    required  Map<int, List<String>> addonsname,
    required  Map<int, List<int>> addonsprice
  }) async {
    final String url = "https://fabspin.org/api/create-laundry";

    final Map<String, dynamic> body = {
      "store_id": storeId.toString(),
      "customer_id": customerId.toString(),
      "itemid": itemIds,
      "price": prices,
      "quant": quantities,
      "selcolor": selcolor,
      "selpattern": selpattern,
      "selbrand": selbrand,
      "selremarks": remarks,
      "addonname": addonsname.map((key, value) => MapEntry(key.toString(), value)),
      "addonprice": addonsprice.map((key, value) => MapEntry(key.toString(), value)),

    };
    final finalUrl = Uri.parse(url);

    try {
      final response = await http.post(
        finalUrl,
        headers: {
          "Content-Type": "application/json", // Ensure Content-Type is set
        },
        body: jsonEncode(body),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        Get.snackbar("Success", "Order booked successfully: ${responseData['message']}");
        final bookingId = responseData['booking_id'];
        Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmStoreBooking(bookingId: bookingId, customerId: customerId, storeId: storeId,)));
        
        
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar("Error", "Failed to book order: ${errorData['error'] ?? 'Unknown error'}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
      print( "An error occurred: $e");

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
        print("Clothes search response: $responseData");

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
          print("No valid search results found.");
        }
      } else {
        print("Failed to search clothes. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during search: $e");
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
