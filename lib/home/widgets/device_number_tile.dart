import 'package:flutter/material.dart';

class DeviceNumberTile extends StatelessWidget {
  const DeviceNumberTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final void Function(double value) onChanged;
  final void Function() onIncrement;
  final void Function() onDecrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                IconButton(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
        Slider(
          min: 50,
          max: 100,
          divisions: 10,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
