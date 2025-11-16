import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/helpers/icon_helper.dart';
import 'package:omni_remote/l10n/l10n.dart';

class GroupPreview extends StatelessWidget {
  const GroupPreview({
    required this.title,
    required this.subtitle,
    required this.iconName,
    super.key,
  });

  final String title;
  final String subtitle;
  final String iconName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Text(
          l10n.modifyGroupPreview,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16),
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
                        icon: IconHelper.getIconByName(iconName),
                        size: 32,
                        strokeWidth: 2,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text(
                              title.isEmpty
                                  ? l10n.modifyGroupGroupTitle
                                  : title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Visibility(
                              visible: subtitle.isNotEmpty,
                              child: Text(
                                subtitle.isEmpty
                                    ? l10n.modifyGroupGroupSubtitle
                                    : subtitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
