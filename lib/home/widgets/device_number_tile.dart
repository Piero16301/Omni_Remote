import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';

class DeviceNumberTile extends StatefulWidget {
  const DeviceNumberTile({
    required this.device,
    required this.group,
    required this.groupIsOnline,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final DeviceModel device;
  final GroupModel group;
  final bool groupIsOnline;
  final void Function() onEdit;
  final void Function() onDelete;

  @override
  State<DeviceNumberTile> createState() => _DeviceNumberTileState();
}

class _DeviceNumberTileState extends State<DeviceNumberTile> {
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;
  bool _isSubscribed = false;
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.device.rangeMin;
    _trySubscribeMqttTopics();
  }

  @override
  void didUpdateWidget(DeviceNumberTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.device.id != widget.device.id ||
        oldWidget.device.title != widget.device.title ||
        oldWidget.group.title != widget.group.title) {
      _isSubscribed = false;
      _value = widget.device.rangeMin;
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

    final status = AppVariables.buildDeviceTopic(
      groupTitle: widget.group.title,
      deviceTitle: widget.device.title,
      suffix: AppVariables.statusSuffix,
    );

    // Cancel any existing subscription
    unawaited(_subscription?.cancel());

    // Listen to the broadcast stream from MqttService FIRST
    _subscription = mqttService.messageStream.listen((
      messages,
    ) {
      for (final message in messages) {
        if (message.topic == status) {
          final payload = message.payload as MqttPublishMessage;
          final messageText = MqttPublishPayload.bytesToStringAsString(
            payload.payload.message,
          );
          final parsedValue = double.tryParse(messageText);

          if (mounted && parsedValue != null) {
            setState(() {
              _value = parsedValue;
            });
          }
        }
      }
    });

    // Now subscribe to MQTT topics - retained messages will be delivered
    // immediately and broadcast to our listener above
    mqttClient.subscribe(status, MqttQos.atMostOnce);
    _isSubscribed = true;
  }

  void _verifyStatus() {
    final mqttService = getIt<MqttService>();
    final mqttClient = mqttService.mqttClient;

    if (mqttClient == null ||
        mqttClient.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }

    final status = AppVariables.buildDeviceTopic(
      groupTitle: widget.group.title,
      deviceTitle: widget.device.title,
      suffix: AppVariables.statusSuffix,
    );

    mqttClient.unsubscribe(status);

    unawaited(_subscription?.cancel());
    _isSubscribed = false;

    _trySubscribeMqttTopics();
  }

  void _publishCommand(double value) {
    final mqttService = getIt<MqttService>();
    final mqttClient = mqttService.mqttClient;

    if (mqttClient == null ||
        mqttClient.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }

    final command = AppVariables.buildDeviceTopic(
      groupTitle: widget.group.title,
      deviceTitle: widget.device.title,
      suffix: AppVariables.commandSuffix,
    );

    final builder = MqttClientPayloadBuilder()
      ..addString(value.toStringAsFixed(1));

    mqttClient.publishMessage(
      command,
      MqttQos.atLeastOnce,
      builder.payload!,
    );

    if (mounted) {
      setState(() {
        _value = value;
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
        }
      },
      child: InkWell(
        onLongPress: () => _showDeviceOptions(
          context,
          widget.device,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              spacing: 16,
              children: [
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Visibility(
                        visible: widget.device.subtitle.isNotEmpty,
                        child: Text(
                          widget.device.subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
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
                      onPressed: widget.groupIsOnline
                          ? () => _publishCommand(
                                _value - widget.device.interval,
                              )
                          : null,
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedRemove01,
                        strokeWidth: 2,
                      ),
                    ),
                    Text(
                      _value.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    IconButton(
                      onPressed: widget.groupIsOnline
                          ? () => _publishCommand(
                                _value + widget.device.interval,
                              )
                          : null,
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
              min: widget.device.rangeMin,
              max: widget.device.rangeMax,
              divisions: widget.device.divisions,
              value: _value,
              onChanged: widget.groupIsOnline
                  ? (value) => setState(() {
                        _value = value;
                      })
                  : null,
              onChangeEnd: widget.groupIsOnline ? _publishCommand : null,
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
                        device.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (device.subtitle.isNotEmpty)
                        Text(
                          device.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const HugeIcon(
                    icon: HugeIcons.strokeRoundedEdit02,
                    strokeWidth: 2,
                  ),
                  title: Text(
                    l10n.homeEditOption,
                    style: Theme.of(context).textTheme.bodyMedium,
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
        builder: (context) {
          return AlertDialog(
            title: Text(
              l10n.homeDeleteDialogTitle(device.title),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            content: Text(
              l10n.homeDeleteDialogContent(device.title),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            actions: [
              AppOutlinedButton(
                onPressed: () => Navigator.pop(context),
                label: l10n.homeDeleteDialogCancel,
              ),
              AppFilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onDelete();
                },
                label: l10n.homeDeleteDialogConfirm,
              ),
            ],
          );
        },
      ),
    );
  }
}
