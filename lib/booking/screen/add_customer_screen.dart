import 'package:fabspinrider/booking/screen/city_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddCustomerScreen extends StatefulWidget {
  final String calledFrom;
  final String? customerId;

  const AddCustomerScreen({
    super.key,
    required this.calledFrom,
    this.customerId,
  });

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
  String? selectedTitle;

  List<City> cities = [];
  List<States> states = [];
  List<String> titles = ['Mr.', 'Ms.', 'Mrs.'];
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchCitiesAndStates();
    if (widget.calledFrom == "edit-customer") {
      loadCustomerData();
    }
  }

  Future<void> loadCustomerData() async {
    if (widget.customerId == null) return;

    final response = await http.get(
      Uri.parse('https://fabspin.org/api/get-customer/${widget.customerId}'),
      headers: {'Accept': 'application/json'},
    );

    debugPrint(
        'Load Customer Data Status Code: ${response.statusCode}\n and this is customerid ${widget.customerId}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        selectedTitle = data['surname'] ?? '';
        firstNameController.text = data['name'] ?? '';
        lastNameController.text = data['lastname'] ?? '';
        mobileController.text = data['mobile'] ?? '';
        address1Controller.text = data['address']['address'] ?? '';
        address2Controller.text = data['address']['address2'] ?? '';
        zipController.text = data['address']['zip'] ?? '';
        emailController.text = data['email'] ?? '';
        gstController.text = data['customer_gst'] ?? '';
        selectedCityId = data['address']['city_id'] is int
            ? data['address']['city_id']
            : int.tryParse(data['address']['city_id'].toString());
        selectedStateId = data['address']['state_id'] is int
            ? data['address']['state_id']
            : int.tryParse(data['address']['state_id'].toString());
        isLoading = false;
      });
    } else {
      debugPrint('Error loading customer data: ${response.body}');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading customer data")),
      );
    }
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

      debugPrint('Fetch States Status Code: ${stateResponse.statusCode}');
      debugPrint('Fetch Cities Status Code: ${cityResponse.statusCode}');

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

          selectedStateId = null;
          selectedCityId = null;
          isLoading = false;
        });
      } else {
        debugPrint(
            'Error fetching states or cities: ${stateResponse.body}, ${cityResponse.body}');
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load data")),
        );
      }
    } catch (e) {
      debugPrint('Exception fetching states or cities: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: $e")),
      );
    }
  }

  Future<void> submitCustomer() async {
    setState(() => isSubmitting = true);

    final url = Uri.parse(widget.calledFrom == "new-customer"
        ? "https://fabspin.org/api/create-customer"
        : "https://fabspin.org/api/update-customer/${widget.customerId}");

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
          "surname": selectedTitle,
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

      debugPrint('Submit Customer Status Code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.calledFrom == "new-customer"
                  ? "Customer added successfully!"
                  : "Customer updated successfully!")),
        );
        Navigator.pop(context);
      } else {
        final responseData = jsonDecode(response.body);
        debugPrint('Error submitting customer: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${responseData['message'] ?? 'Try again'}"),
          ),
        );
      }
    } catch (e) {
      debugPrint('Exception submitting customer: $e');
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

  void _showDropdownDialog(
      BuildContext context,
      String label,
      List<dynamic> items,
      Function(dynamic) onChanged,
      String Function(dynamic) displayText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select $label'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(displayText(item)),
                  onTap: () {
                    onChanged(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.calledFrom == "new-customer"
            ? "Customer Information Form"
            : "Edit Customer Information"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    TextFormField(
                      readOnly: true,
                      onTap: () => _showDropdownDialog(
                        context,
                        "Title",
                        titles,
                        (value) => setState(() => selectedTitle = value),
                        (title) => title,
                      ),
                      decoration: customInputDecoration("Title"),
                      controller: TextEditingController(
                        text: selectedTitle ?? '',
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    TextFormField(
                      readOnly: true,
                      onTap: () => _showDropdownDialog(
                        context,
                        "City",
                        cities,
                        (value) => setState(() => selectedCityId = value.id),
                        (city) => city.name,
                      ),
                      decoration: customInputDecoration("City"),
                      controller: TextEditingController(
                        text: selectedCityId != null
                            ? cities
                                .firstWhere((city) => city.id == selectedCityId)
                                .name
                            : '',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      readOnly: true,
                      onTap: () => _showDropdownDialog(
                        context,
                        "State",
                        states,
                        (value) => setState(() => selectedStateId = value.id),
                        (state) => state.name,
                      ),
                      decoration: customInputDecoration("State"),
                      controller: TextEditingController(
                        text: selectedStateId != null
                            ? states
                                .firstWhere(
                                  (state) => state.id == selectedStateId,
                                  orElse: () =>
                                      States(id: -1, name: ''), // Default value
                                )
                                .name
                            : '',
                      ),
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
