import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.settingsAppBarTitle),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              Card(
                child: RadioGroup<String>(
                  groupValue: state.language,
                  onChanged: (value) {
                    if (value != null) {
                      unawaited(
                        context.read<AppCubit>().changeLanguage(
                          language: value,
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          l10n.settingsLanguageTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      ...AppLocalizations.supportedLocales.map(
                        (locale) => RadioListTile<String>(
                          title: Text(_getLanguageName(locale, l10n)),
                          value:
                              '${locale.languageCode}_'
                              '${locale.languageCode.toUpperCase()}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: RadioGroup<String>(
                  groupValue: state.theme,
                  onChanged: (value) {
                    if (value != null) {
                      unawaited(
                        context.read<AppCubit>().changeTheme(theme: value),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          l10n.settingsThemeTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedSun03,
                              size: 20,
                              strokeWidth: 2,
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.settingsThemeLight),
                          ],
                        ),
                        value: 'LIGHT',
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedMoon02,
                              size: 20,
                              strokeWidth: 2,
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.settingsThemeDark),
                          ],
                        ),
                        value: 'DARK',
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: RadioGroup<String>(
                  groupValue: state.baseColor,
                  onChanged: (value) {
                    if (value != null) {
                      unawaited(
                        context.read<AppCubit>().changeBaseColor(
                          baseColor: value,
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          l10n.settingsBaseColorTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      ...ColorHelper.colorMap.entries.map(
                        (entry) => _buildColorOption(
                          context,
                          entry.key,
                          _getColorName(entry.key, l10n),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    String colorKey,
    String colorName,
  ) {
    final color = ColorHelper.getColorByName(colorKey);

    return RadioListTile<String>(
      title: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(colorName),
        ],
      ),
      value: colorKey,
    );
  }

  String _getLanguageName(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'en':
        return l10n.settingsLanguageEnglish;
      case 'es':
        return l10n.settingsLanguageSpanish;
      default:
        return locale.languageCode;
    }
  }

  String _getColorName(String colorKey, AppLocalizations l10n) {
    switch (colorKey) {
      case 'RED':
        return l10n.settingsColorRed;
      case 'PINK':
        return l10n.settingsColorPink;
      case 'PURPLE':
        return l10n.settingsColorPurple;
      case 'DEEP_PURPLE':
        return l10n.settingsColorDeepPurple;
      case 'INDIGO':
        return l10n.settingsColorIndigo;
      case 'BLUE':
        return l10n.settingsColorBlue;
      case 'LIGHT_BLUE':
        return l10n.settingsColorLightBlue;
      case 'CYAN':
        return l10n.settingsColorCyan;
      case 'TEAL':
        return l10n.settingsColorTeal;
      case 'GREEN':
        return l10n.settingsColorGreen;
      case 'LIGHT_GREEN':
        return l10n.settingsColorLightGreen;
      case 'LIME':
        return l10n.settingsColorLime;
      case 'YELLOW':
        return l10n.settingsColorYellow;
      case 'AMBER':
        return l10n.settingsColorAmber;
      case 'ORANGE':
        return l10n.settingsColorOrange;
      case 'DEEP_ORANGE':
        return l10n.settingsColorDeepOrange;
      case 'BROWN':
        return l10n.settingsColorBrown;
      case 'GREY':
        return l10n.settingsColorGrey;
      case 'BLUE_GREY':
        return l10n.settingsColorBlueGrey;
      default:
        return colorKey;
    }
  }
}
