import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.options,
    this.selected,
    this.leadingIcon,
    this.onChanged,
    super.key,
  });

  final String label;
  final List<DropdownMenuItem<T>> options;
  final T? selected;
  final List<List<dynamic>>? leadingIcon;
  final void Function(T?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropdownButton<T>(
              value: selected,
              isExpanded: true,
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(8),
              onChanged: onChanged,
              items: options,
            ),
          ),
        ),
      ],
    );
  }
}
