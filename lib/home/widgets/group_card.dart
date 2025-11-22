import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_device/modify_device.dart';
import 'package:user_api/user_api.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    required this.group,
    required this.onEnable,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final GroupModel group;
  final void Function() onEnable;
  final void Function() onEdit;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Column(
        children: [
          InkWell(
            onLongPress: () => _showGroupOptions(context, group),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: group.enabled
                  ? Radius.zero
                  : const Radius.circular(16),
              bottomRight: group.enabled
                  ? Radius.zero
                  : const Radius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: group.enabled
                      ? Radius.zero
                      : const Radius.circular(16),
                  bottomRight: group.enabled
                      ? Radius.zero
                      : const Radius.circular(16),
                ),
                color: Theme.of(context).colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  spacing: 16,
                  children: [
                    HugeIcon(
                      icon: IconHelper.getIconByName(group.icon),
                      size: 32,
                      strokeWidth: 2,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            group.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Visibility(
                            visible: group.subtitle.isNotEmpty,
                            child: Text(
                              group.subtitle,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: group.enabled,
                      onChanged: (_) => onEnable(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: group.enabled
                ? ValueListenableBuilder(
                    valueListenable: context
                        .read<HomeCubit>()
                        .getDevicesListenable(),
                    builder: (builderContext, box, widget) {
                      final devices = box.values
                          .where((device) => device.groupId == group.id)
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          spacing: 18,
                          children: devices.isEmpty
                              ? [
                                  Text(
                                    l10n.homeGroupEmptyDevicesMessage,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ]
                              : getDevicesTiles(
                                  context: context,
                                  group: group,
                                  devices: devices,
                                ),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showGroupOptions(BuildContext context, GroupModel group) {
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
                        group.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (group.subtitle.isNotEmpty)
                        Text(
                          group.subtitle,
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
                    _showDeleteConfirmation(context, group);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, GroupModel group) {
    final l10n = AppLocalizations.of(context);

    unawaited(
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(l10n.homeDeleteDialogTitle(group.title)),
            content: Text(l10n.homeDeleteDialogContent(group.title)),
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

  List<Widget> getDevicesTiles({
    required BuildContext context,
    required GroupModel group,
    required List<DeviceModel> devices,
  }) {
    final deviceTiles = <Widget>[];
    for (final device in devices) {
      switch (device.tileType) {
        case DeviceTileType.boolean:
          deviceTiles.add(
            DeviceBooleanTile(
              device: device,
              group: group,
              onEdit: () => context.pushNamed(
                ModifyDevicePage.pageName,
                extra: device,
              ),
              onDelete: () => context.read<HomeCubit>().deleteDevice(device),
            ),
          );
        case DeviceTileType.number:
          deviceTiles.add(
            DeviceNumberTile(
              device: device,
              value: 0,
              onChanged: (value) {},
              onIncrement: () {},
              onDecrement: () {},
              onEdit: () => context.pushNamed(
                ModifyDevicePage.pageName,
                extra: device,
              ),
              onDelete: () => context.read<HomeCubit>().deleteDevice(device),
            ),
          );
      }
    }
    return deviceTiles;
  }
}
