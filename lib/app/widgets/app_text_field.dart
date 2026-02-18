import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.hintText = '',
    this.errorText = '',
    this.overrideErrorText,
    this.isRequired = true,
    this.onChanged,
    this.inputFormatters,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.initialValue,
    this.controller,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.validator,
    super.key,
  });

  final String label;
  final String hintText;
  final String errorText;
  final String? overrideErrorText;
  final bool isRequired;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;
  final String? initialValue;
  final TextEditingController? controller;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        labelText: label,
        hintText: hintText,
        errorText: overrideErrorText,
        prefixIcon: prefix != null
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: prefix,
              )
            : null,
        prefixIconConstraints: prefix != null
            ? const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              )
            : null,
        suffixIcon: suffix,
        suffixIconConstraints: suffix != null
            ? const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              )
            : null,
        alignLabelWithHint: true,
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      initialValue: initialValue,
      validator: validator ??
          (isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return errorText;
                  }
                  return null;
                }
              : null),
    );
  }
}
