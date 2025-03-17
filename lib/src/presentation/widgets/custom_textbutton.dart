import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDisabled;
  final bool isOutlined;
  final double? width; // Add an optional width parameter

  CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isDisabled,
    this.isOutlined = false,
    this.width, // Initialize width
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero, // Remove default padding for full control
      ),
      child: Container(
        width: width ?? double.infinity, // Apply custom width if provided
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey[400]
              : isOutlined
              ? Colors.transparent
              : Colors.black,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isOutlined ? Colors.black : Colors.transparent,
            width: isOutlined ? 1 : 0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isOutlined ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
