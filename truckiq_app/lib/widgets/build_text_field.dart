import 'package:flutter/material.dart';

class BuildTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumber;

  const BuildTextField({super.key, required this.label, required this.controller, this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required";
          }

          if (isNumber) {
            final number = int.tryParse(value);
            if (number == null) {
              return "Must be a number";
            }
            if (number < 0) {
              return "Cannot be negative";
            }
          }

          return null;
        },
      ),
    );
  }
}
