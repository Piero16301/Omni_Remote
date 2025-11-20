import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class DeviceNumberTile extends StatelessWidget {
  const DeviceNumberTile({
    required this.device,
    required this.value,
    required this.onChanged,
    required this.onIncrement,
    required this.onDecrement,
    required this.onEdit,
    required this.onDelete,
    this.online = false,
    super.key,
  });

  final DeviceModel device;
  final double value;
  final void Function(double value) onChanged;
  final void Function() onIncrement;
  final void Function() onDecrement;
  final void Function() onEdit;
  final void Function() onDelete;
  final bool online;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => _showDeviceOptions(
        context,
        device,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Row(
            spacing: 16,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: online ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              HugeIcon(
                icon: IconHelper.getIconByName(device.icon),
                size: 28,
                strokeWidth: 2,
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
                    Visibility(
                      visible: device.subtitle.isNotEmpty,
                      child: Text(
                        device.subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
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
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedRemove01,
                      strokeWidth: 2,
                    ),
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
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      strokeWidth: 2,
                    ),
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
      ),
    );
  }

  void _showDeviceOptions(BuildContext context, DeviceModel device) {
    final l10n = AppLocalizations.of(context);

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 8,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    spacing: 4,
                    children: [
                      Text(
                        device.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (device.subtitle.isNotEmpty)
                        Text(
                          device.subtitle,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedEdit02,
                    strokeWidth: 2,
                  ),
                  title: Text(l10n.homeEditOption),
                  onTap: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                ),
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    strokeWidth: 2,
                  ),
                  title: Text(l10n.homeDeleteOption),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, device);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DeviceModel device) {
    final l10n = AppLocalizations.of(context);

    unawaited(
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(l10n.homeDeleteDialogTitle(device.title)),
            content: Text(l10n.homeDeleteDialogContent(device.title)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.homeDeleteDialogCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onDelete();
                },
                child: Text(l10n.homeDeleteDialogConfirm),
              ),
            ],
          );
        },
      ),
    );
  }
}
