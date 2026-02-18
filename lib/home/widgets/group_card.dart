import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/home/home.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_device/modify_device.dart';

class GroupCard extends StatefulWidget {
  const GroupCard({
    required this.group,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final GroupModel group;
  final void Function() onEdit;
  final void Function() onDelete;

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;
  bool _isSubscribed = false;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _trySubscribeMqttTopics();
  }

  @override
  void didUpdateWidget(covariant GroupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.id != widget.group.id ||
        oldWidget.group.title != widget.group.title) {
      _isOnline = false;
      _isSubscribed = false;
      _verifyStatus();
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _trySubscribeMqttTopics() {
    final mqttService = getIt<MqttService>();
    final mqttClient = mqttService.mqttClient;

    if (mqttClient == null ||
        mqttClient.connectionStatus?.state != MqttConnectionState.connected ||
        _isSubscribed) {
      return;
    }

    final online = AppVariables.buildGroupTopic(
      groupTitle: widget.group.title,
      suffix: AppVariables.onlineSuffix,
    );

    // Cancel any existing subscription first
    unawaited(_subscription?.cancel());

    // Listen to the broadcast stream from MqttService FIRST
    _subscription = mqttService.messageStream.listen((
      messages,
    ) {
      for (final message in messages) {
        if (message.topic == online) {
          final payload = message.payload as MqttPublishMessage;
          final messageText = MqttPublishPayload.bytesToStringAsString(
            payload.payload.message,
          );

          if (mounted) {
            setState(() {
              _isOnline = messageText == '1';
            });
          }
        }
      }
    });

    // Now subscribe to MQTT topics - retained messages will be delivered
    // immediately and broadcast to our listener above
    mqttClient.subscribe(online, MqttQos.atLeastOnce);
    _isSubscribed = true;
  }

  void _verifyStatus() {
    final mqttService = getIt<MqttService>();
    final mqttClient = mqttService.mqttClient;

    if (mqttClient == null ||
        mqttClient.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }

    // Unsubscribe from current topics
    final online = AppVariables.buildGroupTopic(
      groupTitle: widget.group.title,
      suffix: AppVariables.onlineSuffix,
    );

    mqttClient.unsubscribe(online);

    unawaited(_subscription?.cancel());
    _isSubscribed = false;

    _trySubscribeMqttTopics();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Column(
        children: [
          InkWell(
            onLongPress: () => _showGroupOptions(context, widget.group),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
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
                      icon: IconHelper.getIconByName(widget.group.icon),
                      size: 32,
                      strokeWidth: 2,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            widget.group.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Visibility(
                            visible: widget.group.subtitle.isNotEmpty,
                            child: Text(
                              widget.group.subtitle,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HugeIcon(
                      icon: _isOnline
                          ? HugeIcons.strokeRoundedWifiConnected02
                          : HugeIcons.strokeRoundedWifiDisconnected02,
                      strokeWidth: 2,
                      color: _isOnline ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: context.read<HomeCubit>().getDevicesListenable(),
            builder: (builderContext, devices, widgetBuilder) {
              final devicesInGroup = devices
                  .where((device) => device.groupId == widget.group.id)
                  .toList();

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  spacing: 18,
                  children: devicesInGroup.isEmpty
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
                          group: widget.group,
                          devices: devicesInGroup,
                        ),
                ),
              );
            },
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
        builder: (context) {
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (group.subtitle.isNotEmpty)
                        Text(
                          group.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowReloadHorizontal,
                    strokeWidth: 2,
                  ),
                  title: Text(
                    l10n.homeReconnectOption,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _verifyStatus();
                  },
                ),
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedEdit02,
                    strokeWidth: 2,
                  ),
                  title: Text(
                    l10n.homeEditOption,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onEdit();
                  },
                ),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    l10n.homeDeleteOption,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
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
        builder: (context) {
          return AlertDialog(
            title: Text(
              l10n.homeDeleteDialogTitle(group.title),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            content: Text(
              l10n.homeDeleteDialogContent(group.title),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.homeDeleteDialogCancel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete();
                },
                child: Text(
                  l10n.homeDeleteDialogConfirm,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
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
              groupIsOnline: _isOnline,
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
              group: group,
              groupIsOnline: _isOnline,
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
