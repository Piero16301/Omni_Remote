import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppIconSelector extends StatelessWidget {
  const AppIconSelector({
    required this.label,
    required this.iconOptions,
    required this.selectedIcon,
    required this.onIconSelected,
    super.key,
  });

  final String label;
  final Map<String, List<List<dynamic>>> iconOptions;
  final String selectedIcon;
  final ValueChanged<String> onIconSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const crossAxisCount = 3;
              const crossAxisSpacing = 12.0;
              const mainAxisSpacing = 12.0;
              const padding = 16.0;
              const cellSize = 55.0;

              return SizedBox(
                height: (cellSize * crossAxisCount) +
                    (crossAxisSpacing * (crossAxisCount - 1)) +
                    (padding * 2),
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(padding),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                    mainAxisExtent: cellSize,
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
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  )
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
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
              );
            },
          ),
        ),
      ],
    );
  }
}
