import 'package:flutter/material.dart';

class DeviceBooleanTile extends StatelessWidget {
  const DeviceBooleanTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final void Function({bool? value}) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Icon(icon, size: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (value) => onChanged(value: value),
        ),
      ],
    );
  }
}
