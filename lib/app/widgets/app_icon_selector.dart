import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/l10n/l10n.dart';

class AppIconSelector extends StatelessWidget {
  const AppIconSelector({
    required this.iconOptions,
    required this.selectedIcon,
    required this.onIconSelected,
    super.key,
  });

  final Map<String, List<List<dynamic>>> iconOptions;
  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.modifyGroupSelectIcon,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: iconOptions.length,
            itemBuilder: (context, index) {
              final entry = iconOptions.entries.elementAt(index);
              final iconName = entry.key;
              final iconData = entry.value;
              final isSelected = selectedIcon == iconName;

              return InkWell(
                onTap: () => onIconSelected(iconName),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withValues(
                            alpha: 0.2,
                          )
                        : Theme.of(context).colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: iconData,
                      size: 28,
                      strokeWidth: 2,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
