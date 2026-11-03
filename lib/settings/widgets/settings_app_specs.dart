import 'package:expressive_kit/expressive_kit.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsAppSpecs extends StatelessWidget {
  const SettingsAppSpecs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final version = snapshot.data?.version ?? '';
        final buildNumber = snapshot.data?.buildNumber ?? '';
        final updateDate = snapshot.data?.updateTime ?? DateTime.now();

        return ExpressiveCardGroup(
          title: l10n.settingsVersionTitle,
          children: [
            ExpressiveListTile(
              leading: ExpressiveBadge(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedInformationCircle,
                  strokeWidth: 2,
                ),
              ),
              title: Text(l10n.settingsVersionTitle),
              subtitle: Text('$version ($buildNumber)'),
            ),
            ExpressiveListTile(
              leading: ExpressiveBadge(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  strokeWidth: 2,
                ),
              ),
              title: Text(l10n.settingsUpdateDateTitle),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(updateDate)),
            ),
          ],
        );
      },
    );
  }
}
