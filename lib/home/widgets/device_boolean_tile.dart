import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class DeviceBooleanTile extends StatefulWidget {
  const DeviceBooleanTile({
    required this.device,
    required this.group,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DeviceModel device;
  final GroupModel group;
  final void Function() onEdit;
  final void Function() onDelete;

  @override
  State<DeviceBooleanTile> createState() => _DeviceBooleanTileState();
}

class _DeviceBooleanTileState extends State<DeviceBooleanTile> {
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;
  bool _isSubscribed = false;
  bool _isOnline = false;
  bool _isOn = false;

  @override
  void initState() {
    super.initState();
    _trySubscribeMqttTopics();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _trySubscribeMqttTopics() {
    final appCubit = context.read<AppCubit>();
    final mqttClient = appCubit.mqttClient;

    if (mqttClient == null ||
        mqttClient.connectionStatus?.state != MqttConnectionState.connected ||
        _isSubscribed) {
      return;
    }

    // Subscribe to MQTT topics
    final online = AppVariables.buildDeviceTopic(
      groupTitle: widget.group.title,
      deviceTitle: widget.device.title,
      suffix: AppVariables.onlineSuffix,
    );
    final status = AppVariables.buildDeviceTopic(
      groupTitle: widget.group.title,
      deviceTitle: widget.device.title,
      suffix: AppVariables.statusSuffix,
    );

    mqttClient
      ..subscribe(online, MqttQos.atLeastOnce)
      ..subscribe(status, MqttQos.atLeastOnce);
    _isSubscribed = true;

    _subscription = mqttClient.updates?.listen((
      List<MqttReceivedMessage<MqttMessage>> messages,
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
        } else if (message.topic == status) {
          final payload = message.payload as MqttPublishMessage;
          final messageText = MqttPublishPayload.bytesToStringAsString(
            payload.payload.message,
          );

          if (mounted) {
            setState(() {
              _isOn = messageText == '1';
            });
          }
        }
      }
    });
  }

  void _publishCommand(bool value) {
    final appCubit = context.read<AppCubit>();
    final mqttClient = appCubit.mqttClient;

    if (mqttClient == null ||
        mqttClient.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }

    final command = AppVariables.buildDeviceTopic(
      groupTitle: widget.group.title,
      deviceTitle: widget.device.title,
      suffix: AppVariables.commandSuffix,
    );

    final builder = MqttClientPayloadBuilder()..addString(value ? '1' : '0');

    mqttClient.publishMessage(
      command,
      MqttQos.atLeastOnce,
      builder.payload!,
    );

    if (mounted) {
      setState(() {
        _isOn = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) =>
          previous.brokerConnectionStatus != current.brokerConnectionStatus,
      listener: (context, state) {
        if (state.brokerConnectionStatus.isConnected) {
          _trySubscribeMqttTopics();
        } else if (state.brokerConnectionStatus.isDisconnected) {
          _isSubscribed = false;
          if (mounted) {
            setState(() {
              _isOnline = false;
            });
          }
        }
      },
      child: InkWell(
        onLongPress: () => _showDeviceOptions(
          context,
          widget.device,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          spacing: 16,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isOnline ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            HugeIcon(
              icon: IconHelper.getIconByName(widget.device.icon),
              size: 28,
              strokeWidth: 2,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    widget.device.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Visibility(
                    visible: widget.device.subtitle.isNotEmpty,
                    child: Text(
                      widget.device.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isOn,
              onChanged: _publishCommand,
            ),
          ],
        ),
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
                    widget.onEdit();
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
                  widget.onDelete();
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
