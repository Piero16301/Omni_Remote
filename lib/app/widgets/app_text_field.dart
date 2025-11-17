import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.initialValue,
    required this.onChanged,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.validator,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String labelText;
  final String hintText;
  final dynamic prefixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.sentences,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: HugeIcon(
              icon: prefixIcon as List<List<dynamic>>,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      validator: validator,
    );
  }
}
