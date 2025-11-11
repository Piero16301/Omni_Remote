import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';

class DeviceBooleanTile extends StatelessWidget {
  const DeviceBooleanTile({
    required this.device,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DeviceModel device;
  final bool value;
  final void Function({bool? value}) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Switch(
          value: value,
          onChanged: (value) => onChanged(value: value),
        ),
      ],
    );
  }
}
