import 'package:flutter/material.dart';

class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
    );
  }
}

class States {
  final int id;
  final String name;

  States({required this.id, required this.name});

  factory States.fromJson(Map<String, dynamic> json) {
    return States(
      id: json['id'],
      name: json['name'],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<dynamic> items;
  final Function(T) onChanged;
  final String Function(dynamic) displayText;
  final T Function(dynamic) getValue;

  const CustomDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.displayText,
    required this.getValue,
  });

  @override
  Widget build(BuildContext context) {
    String? displayText;
    if (value != null) {
      try {
        dynamic item = items.firstWhere((item) => getValue(item) == value);
        displayText = this.displayText(item);
      } catch (e) {
        displayText = label; // Fallback to label if value is invalid
      }
    } else {
      displayText =
          label; // Initial text is the label (e.g., "Title", "City", "State")
    }

    return GestureDetector(
      onTap: () => _showDropdownDialog(context),
      child: InputDecorator(
        decoration: _customInputDecoration(label),
        child: Text(
          displayText,
          style: TextStyle(
            color: value != null
                ? Colors.black87
                : Colors.grey, // Grey when unselected
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showDropdownDialog(BuildContext context) {
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
                    T selectedValue = getValue(item);
                    onChanged(selectedValue);
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

  InputDecoration _customInputDecoration(String label) {
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
}
