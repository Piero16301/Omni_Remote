import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';

class DeviceNumberTile extends StatelessWidget {
  const DeviceNumberTile({
    required this.device,
    required this.value,
    required this.onChanged,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  final DeviceModel device;
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
            HugeIcon(
              icon: IconHelper.getIconByName(device.icon),
              size: 28,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    device.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    device.subtitle,
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
          min: device.rangeMin,
          max: device.rangeMax,
          divisions: device.divisions,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
