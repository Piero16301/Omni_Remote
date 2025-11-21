import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MqttTopicsInfo extends StatelessWidget {
  const MqttTopicsInfo({
    required this.groupTitle,
    required this.deviceTitle,
    required this.tileType,
    super.key,
  });

  final String groupTitle;
  final String deviceTitle;
  final DeviceTileType tileType;

  String _normalizeText(String text) {
    // Convertir a minúsculas
    var normalized = text.toLowerCase();

    // Reemplazar tildes por vocales normales
    normalized = normalized
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');

    // Reemplazar espacios por guiones medios
    normalized = normalized.replaceAll(RegExp(r'\s+'), '-');

    return normalized;
  }

  String _buildTopic(String suffix) {
    final normalizedGroup = _normalizeText(groupTitle);
    final normalizedDevice = _normalizeText(deviceTitle);
    return '$normalizedGroup/$normalizedDevice/$suffix';
  }

  void _copyToClipboard(BuildContext context, String message, String text) {
    unawaited(Clipboard.setData(ClipboardData(text: text)));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (groupTitle.isEmpty || deviceTitle.isEmpty) {
      return const SizedBox.shrink();
    }

    final onlineTopic = _buildTopic('online');
    final statusTopic = _buildTopic('status');
    final commandTopic = _buildTopic('command');

    return Column(
      children: [
        Text(
          l10n.modifyDeviceMqttTopics,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
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
                  Icon(
                    Icons.info_outline,
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: getTopicStatusDescription(tileType, l10n),
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
                  Icon(
                    Icons.info_outline,
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: getTopicCommandDescription(tileType, l10n),
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

  String getTopicStatusDescription(DeviceTileType type, AppLocalizations l10n) {
    switch (type) {
      case DeviceTileType.boolean:
        return l10n.modifyDeviceMqttTopicStatusDescriptionBool;
      case DeviceTileType.number:
        return l10n.modifyDeviceMqttTopicStatusDescriptionNumber;
    }
  }

  String getTopicCommandDescription(
    DeviceTileType type,
    AppLocalizations l10n,
  ) {
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
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
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
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              topic,
              style: theme.textTheme.bodySmall?.copyWith(
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
