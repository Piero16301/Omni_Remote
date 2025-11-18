import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class TileTypeSelector extends StatelessWidget {
  const TileTypeSelector({
    required this.selectedType,
    required this.onTypeSelected,
    super.key,
  });

  final DeviceTileType selectedType;
  final ValueChanged<DeviceTileType> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.modifyDeviceTileTypeLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<DeviceTileType>(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 20),
              ),
              side: WidgetStateProperty.resolveWith<BorderSide?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    );
                  }
                  return null;
                },
              ),
            ),
            segments: [
              ButtonSegment<DeviceTileType>(
                value: DeviceTileType.boolean,
                label: Text(
                  l10n.modifyDeviceTileTypeBoolean,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: selectedType == DeviceTileType.boolean
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectedType == DeviceTileType.boolean
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedToggleOn,
                  size: 30,
                  strokeWidth: 2,
                  color: selectedType == DeviceTileType.boolean
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).iconTheme.color,
                ),
              ),
              ButtonSegment<DeviceTileType>(
                value: DeviceTileType.number,
                label: Text(
                  l10n.modifyDeviceTileTypeNumber,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: selectedType == DeviceTileType.number
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectedType == DeviceTileType.number
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedLeftToRightListNumber,
                  size: 30,
                  strokeWidth: 2,
                  color: selectedType == DeviceTileType.number
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).iconTheme.color,
                ),
              ),
            ],
            selected: {selectedType},
            onSelectionChanged: (Set<DeviceTileType> newSelection) {
              onTypeSelected(newSelection.first);
            },
            showSelectedIcon: false,
          ),
        ),
      ],
    );
  }
}
