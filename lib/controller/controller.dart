import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../model/order.dart';
import '../screen/home_screen.dart';

class RiderController extends GetxController {
  var name = ''.obs;
  var mobile = ''.obs;
  var storedAddress = ''.obs;
  var email = ''.obs;
  var mobileNumber = TextEditingController();
  var passwordController = TextEditingController();
  var isLoading = false.obs;
  //var userID = ''.obs;
  var pickCount = ''.obs;
  var dropCount = ''.obs;


  var pickupAddress = ''.obs;
  var deliverAddress = ''.obs;
  var storeCode = ''.obs;
  var type = ''.obs;
  var pickupDate = ''.obs;
  var pickupTime = ''.obs;
  var customerName = ''.obs;
  var customerMobile = ''.obs;
  RxList<Map<String, dynamic>> pickupDropDataList = <Map<String, dynamic>>[].obs;
  RxInt dataLength = 0.obs; // To store the length of the data
  RxList<PickupDrop> orders = <PickupDrop>[].obs;
  RxList<PickupDrop> filteredOrders = <PickupDrop>[].obs;
  var totalClothes = 0.obs;
  var selectedTab = 'New Orders'.obs;


  @override
  void onInit() {
    super.onInit();
    getUser();
  }
  
  
  Future<void> updateFcm(String userId, String fcm)async{
    final url = Uri.parse('https://fabspin.org/api/update-rider-fcm/$userId');
    print(url);
    print(userId);
    print("My FCM $fcm");
    final response = await http.post(url, body: {
      'fcm': fcm
    });

    if(response.statusCode == 200){
      final responseData = jsonDecode(response.body);
      print(responseData);
    }else{
      print('Error Updating Fcm');
    }

  }


  Future<void> updatePickup(String orderId) async {
    final url = Uri.parse('https://fabspin.org/api/update-pickup-drops/$orderId');
    print(url);

    // Prepare the request body
    Map<String, String> body = {
      'status': selectedTab.value == 'Accepted' ? 4.toString() : 2.toString(),
    };

    // Add total_clothes only when selectedTab is 0
    if (selectedTab.value == 'Accepted') {
      body['total_clothes'] = totalClothes.value.toString();
    }

    // Debugging: Print the body and selectedTab value
    print('selectedTab.value: ${selectedTab.value}');
    print('Request body: $body');

    // Send the POST request
    final response = await http.post(
      url,
      body: body,
    );

    // Handle response
    if (response.statusCode == 200) {
      print(response.body);
      print("Pickup updated successfully!");
    } else {
      print("Error updating pickup: ${response.statusCode}");
      print("Response body: ${response.body}"); // Log the response body to check for server-side error messages
    }
  }



  Future<void> denyOrder(String orderId, String status) async {
    print(status);
    final url = Uri.parse('https://fabspin.org/api/update-pickup-drops/$orderId');

    // Prepare the request body
    Map<String, String> body = {
      'status': status,
    };

    // Add total_clothes only when selectedTab is 0


    // Debugging: Print the body and selectedTab value
    print('selectedTab.value: ${selectedTab.value}');
    print('Request body: $body');

    // Send the POST request
    final response = await http.post(
      url,
      body: body,
    );

    // Handle response
    if (response.statusCode == 200) {
      print("Cancelled successfully!");
    } else {
      print("Error Cancelled pickup: ${response.statusCode}");
      print("Response body: ${response.body}"); // Log the response body to check for server-side error messages
    }
  }



  // Counter logic
  void incrementClothes() {
    totalClothes++;
  }

  void decrementClothes() {
    if (totalClothes > 0) totalClothes--;
  }



  // Method to update selected tab and filter orders
  void updateSelectedTab(String tab) {
    selectedTab.value = tab;
    filterOrdersByTab(tab);
  }


  void filterOrdersByTab(String tab) {
    if (tab == 'New Orders') {
      filteredOrders.value = orders.where((order) => order.status == 'Pending').toList();
    } else if (tab == 'Accepted') {
      filteredOrders.value = orders.where((order) => order.status == 'Accepted').toList();
    } else if (tab == 'Picked Up') {
      filteredOrders.value = orders.where((order) => order.status == 'Picked Up').toList();
    }else if (tab == 'Deny') {
      filteredOrders.value = orders.where((order) => order.status == 'Canceled').toList();
    } else {
      filteredOrders.value = orders; // Show all orders if no specific tab is selected
    }
  }



  // Method to register the user
  Future<void> registerUser() async {
    isLoading.value = true;
    final url = Uri.parse('https://fabspin.org/api/rider-login');

    final response = await http.post(
      url,
      body: json.encode({
        "mobile": mobileNumber.text,
        "password": passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['Status'] == 'Success') {
        await _saveUserId(
          responseData['user_id'],
          responseData['mobile'],
          responseData['name'],
          responseData['store'],
          responseData['email'] ?? '',
        );
        Get.offAll(() => HomeScreen());
      } else {
        Get.snackbar('Error', 'Enter Correct User Id, Password', colorText: CupertinoColors.white,
            snackPosition: SnackPosition.TOP);
      }
    } else {
      Get.snackbar('Error', 'An error occurred. Please try again later.',
          snackPosition: SnackPosition.TOP);
    }
    isLoading.value = false;
  }



  Future<void> getPickupDropListData(int riderId) async {
    final url = Uri.parse('https://fabspin.org/api/pickup-drop-list/$riderId');
    print('Request URL: $url');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response body: $responseData');

        if (responseData['Status'] == 'Success' && responseData['data'] is List) {
          orders.value = (responseData['data'] as List)
              .map((entry) => PickupDrop.fromJson(entry))
              .toList()
              .cast<PickupDrop>(); // Explicitly cast to List<PickupDrop>

          // Now filter based on the current tab
          filterOrdersByTab(selectedTab.value);
        } else {
          print('Failed to load data: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }









  // Save user details in SharedPreferences
  Future<void> _saveUserId(int userId, String mobile, String name, String store, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
    await prefs.setString('mobile', mobile);
    await prefs.setString('name', name);
    await prefs.setString('store', store);
    await prefs.setString('email', email);

  }

  // Form validation
  void validateForm() {
    if (mobileNumber.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter your Phone Number');
    } else if (passwordController.text.isEmpty) {
      Get.snackbar('Validation Error', 'Please enter your Password');
    } else {
      registerUser();
    }
  }


  Future<void> getRiderHomeData(int riderId) async {
    final url = Uri.parse('https://fabspin.org/api/rider-home/$riderId');
    print(url);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Successful request
        final responseData = jsonDecode(response.body);
        print(responseData);
        pickCount.value = responseData['pickup_count'].toString();
        dropCount.value = responseData['drop_count'].toString();
        print(pickCount.value);
        print(dropCount.value);

      } else {
        // Handle other status codes
        print('Failed to load data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error occurred: $e');
      return null;
    }
  }




  void getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var userId = pref.getInt('user_id') ?? 0;
    name.value = pref.getString('name') ?? '';
    mobile.value = pref.getString('mobile') ?? '';
    storedAddress.value = pref.getString('store') ?? '';
    email.value = pref.getString('email') ?? '';
    print('User ID -----> $userId');
    getRiderHomeData(userId);
    getPickupDropListData(userId);
  }
}
