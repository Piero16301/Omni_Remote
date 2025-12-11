import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.initialValue,
    required this.onChanged,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String labelText;
  final String hintText;
  final dynamic prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: HugeIcon(
                    icon: prefixIcon as List<List<dynamic>>,
                    strokeWidth: 2,
                  ),
                ),
              )
            : null,
        suffixIcon: suffixIcon,
        errorMaxLines: 3,
      ),
      validator: validator,
    );
  }
}
