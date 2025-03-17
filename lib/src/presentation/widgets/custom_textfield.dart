import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final bool noIcon;
  final bool isDisabled;
  final String? initialValue;
  final Function(String)? onChanged;
  final String? errorText;
  final bool isNumPad;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.noIcon = true,
    this.isDisabled = false,
    this.initialValue,
    this.onChanged,
    this.errorText = '',
    this.isNumPad = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focus = FocusNode();
  bool isNotFocus = true;
  bool isObscure = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    setState(() {
      isNotFocus = !isNotFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      focusNode: _focus,
      initialValue: widget.initialValue,
      style: TextStyle(
        color: widget.isDisabled ? Colors.grey[400] : Colors.black,
      ),
      readOnly: widget.isDisabled,
      keyboardType: widget.isNumPad ? TextInputType.number : null,
      controller: widget.controller,
      decoration: InputDecoration(
        errorText: widget.errorText == '' ? null : widget.errorText,
        suffixIconColor: Colors.cyan,
        suffixIcon: widget.noIcon
            ? const SizedBox()
            : IconButton(
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: isObscure
                    ? const Icon(Icons.visibility_outlined)
                    : const Icon(Icons.visibility_off_outlined),
              ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: widget.errorText != ''
              ? Colors.red
              : widget.isDisabled
                  ? Colors.grey[700]!
                  : !isNotFocus
                      ? Colors.black
                      : Colors.grey[600],
          fontSize: widget.isDisabled
              ? 20
              : !isNotFocus
                  ? 20
                  : 15,
        ),
        contentPadding: const EdgeInsets.all(15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: widget.isDisabled ? Colors.grey[500]! : Colors.black,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.black,
          ),
        ),
      ),
      obscureText: isObscure,
    );
  }
}
