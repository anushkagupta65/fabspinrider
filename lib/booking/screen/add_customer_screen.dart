import 'package:fabspinrider/booking/screen/city_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  int? selectedCityId;
  int? selectedStateId;

  List<City> cities = [];
  List<States> states = [];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchCitiesAndStates();
  }

  Future<void> fetchCitiesAndStates() async {
    try {
      final stateResponse = await http.get(
        Uri.parse('https://fabspin.org/api/get-states'),
        headers: {'Accept': 'application/json'},
      );

      final cityResponse = await http.get(
        Uri.parse('https://fabspin.org/api/get-cities'),
        headers: {'Accept': 'application/json'},
      );

      if (stateResponse.statusCode == 200 && cityResponse.statusCode == 200) {
        final stateJson = jsonDecode(stateResponse.body);
        final cityJson = jsonDecode(cityResponse.body);

        setState(() {
          states = (stateJson['data'] as List)
              .map((state) => States.fromJson(state))
              .toList();
          cities = (cityJson['data'] as List)
              .map((city) => City.fromJson(city))
              .toList();

          selectedStateId = states.isNotEmpty ? states[0].id : null;
          selectedCityId = cities.isNotEmpty ? cities[0].id : null;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load data")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
    }
  }

  Future<void> submitCustomer() async {
    setState(() => isSubmitting = true);

    final url = Uri.parse("https://fabspin.org/api/create-customer");

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getInt('StoreId');

      if (storeId == null) {
        debugPrint("Store ID is null");
        return;
      }

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "store_id": storeId,
          "name": firstNameController.text,
          "lastname": lastNameController.text,
          "mobile": mobileController.text,
          "address": address1Controller.text,
          "address2": address2Controller.text,
          "zip": zipController.text,
          "city_id": selectedCityId,
          "state_id": selectedStateId,
          "email": emailController.text,
          "customer_gst": gstController.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Customer added successfully!")),
        );
        Navigator.pop(context);
      } else {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${responseData['message'] ?? 'Try again'}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87, fontSize: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 14.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customer Information")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: firstNameController,
                      decoration: customInputDecoration("First Name"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: lastNameController,
                      decoration: customInputDecoration("Last Name"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: customInputDecoration("Mobile No"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: address1Controller,
                      decoration: customInputDecoration("Address Line 1"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: address2Controller,
                      decoration: customInputDecoration("Address Line 2"),
                    ),
                    const SizedBox(height: 20),
                    CustomDropdown<int>(
                      label: "City",
                      value: selectedCityId,
                      items: cities,
                      onChanged: (value) {
                        setState(() => selectedCityId = value);
                      },
                      displayText: (city) => city.name,
                      getValue: (city) => city.id,
                    ),
                    const SizedBox(height: 20),
                    CustomDropdown<int>(
                      label: "State",
                      value: selectedStateId,
                      items: states,
                      onChanged: (value) {
                        setState(() => selectedStateId = value);
                      },
                      displayText: (state) => state.name,
                      getValue: (state) => state.id,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: zipController,
                      keyboardType: TextInputType.number,
                      decoration: customInputDecoration("Zip"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: customInputDecoration("Email"),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: gstController,
                      decoration: customInputDecoration("Customer GST No."),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submitCustomer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Submit",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
