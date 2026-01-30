import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MqttTopicsInfo extends StatelessWidget {
  const MqttTopicsInfo({
    required this.topicInfoType,
    this.groupTitle,
    this.deviceTitle,
    this.deviceTileType,
    super.key,
  });

  final TopicInfoType topicInfoType;
  final String? groupTitle;
  final String? deviceTitle;
  final DeviceTileType? deviceTileType;

  void _copyToClipboard(BuildContext context, String message, String text) {
    unawaited(Clipboard.setData(ClipboardData(text: text)));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (topicInfoType) {
      case TopicInfoType.group:
        if (groupTitle == null) {
          return const SizedBox.shrink();
        }

        final onlineTopic = AppVariables.buildGroupTopic(
          groupTitle: groupTitle!,
          suffix: AppVariables.onlineSuffix,
        );

        return topicInfoGroup(
          context: context,
          onlineTopic: onlineTopic,
        );
      case TopicInfoType.device:
        if (groupTitle == null ||
            deviceTitle == null ||
            deviceTileType == null) {
          return const SizedBox.shrink();
        }

        final statusTopic = AppVariables.buildDeviceTopic(
          groupTitle: groupTitle!,
          deviceTitle: deviceTitle!,
          suffix: AppVariables.statusSuffix,
        );
        final commandTopic = AppVariables.buildDeviceTopic(
          groupTitle: groupTitle!,
          deviceTitle: deviceTitle!,
          suffix: AppVariables.commandSuffix,
        );

        return topicInfoDevice(
          context: context,
          statusTopic: statusTopic,
          commandTopic: commandTopic,
        );
    }
  }

  Widget topicInfoGroup({
    required BuildContext context,
    required String onlineTopic,
  }) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Text(
          l10n.modifyDeviceMqttTopics,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                _TopicItem(
                  label: l10n.modifyDeviceMqttTopicOnline,
                  topic: onlineTopic,
                  onCopy: () => _copyToClipboard(
                    context,
                    l10n.modifyDeviceMqttSnackbarCopy(
                      l10n.modifyDeviceMqttTopicOnline,
                    ),
                    onlineTopic,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          TextSpan(
                            text: '${l10n.modifyDeviceMqttTopicOnline}: ',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          TextSpan(
                            text: l10n.modifyDeviceMqttTopicOnlineDescription,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget topicInfoDevice({
    required BuildContext context,
    required String statusTopic,
    required String commandTopic,
  }) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Text(
          l10n.modifyDeviceMqttTopics,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                _TopicItem(
                  label: l10n.modifyDeviceMqttTopicStatus,
                  topic: statusTopic,
                  onCopy: () => _copyToClipboard(
                    context,
                    l10n.modifyDeviceMqttSnackbarCopy(
                      l10n.modifyDeviceMqttTopicStatus,
                    ),
                    statusTopic,
                  ),
                ),
                _TopicItem(
                  label: l10n.modifyDeviceMqttTopicCommand,
                  topic: commandTopic,
                  onCopy: () => _copyToClipboard(
                    context,
                    l10n.modifyDeviceMqttSnackbarCopy(
                      l10n.modifyDeviceMqttTopicCommand,
                    ),
                    commandTopic,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          TextSpan(
                            text: '${l10n.modifyDeviceMqttTopicStatus}: ',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          TextSpan(
                            text: getTopicStatusDescription(
                              l10n: l10n,
                              type: deviceTileType,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          TextSpan(
                            text: '${l10n.modifyDeviceMqttTopicCommand}: ',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          TextSpan(
                            text: getTopicCommandDescription(
                              type: deviceTileType,
                              l10n: l10n,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String getTopicStatusDescription({
    required AppLocalizations l10n,
    DeviceTileType? type,
  }) {
    if (type == null) {
      return '';
    }

    switch (type) {
      case DeviceTileType.boolean:
        return l10n.modifyDeviceMqttTopicStatusDescriptionBool;
      case DeviceTileType.number:
        return l10n.modifyDeviceMqttTopicStatusDescriptionNumber;
    }
  }

  String getTopicCommandDescription({
    required AppLocalizations l10n,
    DeviceTileType? type,
  }) {
    if (type == null) {
      return '';
    }

    switch (type) {
      case DeviceTileType.boolean:
        return l10n.modifyDeviceMqttTopicCommandDescriptionBool;
      case DeviceTileType.number:
        return l10n.modifyDeviceMqttTopicCommandDescriptionNumber;
    }
  }
}

class _TopicItem extends StatelessWidget {
  const _TopicItem({
    required this.label,
    required this.topic,
    required this.onCopy,
  });

  final String label;
  final String topic;
  final void Function() onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              topic,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onCopy,
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedCopy01,
            size: 20,
            strokeWidth: 2,
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
