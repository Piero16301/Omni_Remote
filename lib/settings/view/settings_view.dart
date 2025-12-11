import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/settings/settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.settingsAppBarTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                strokeWidth: 2,
              ),
            ),
          ),
          body: ListView(
            children: [
              SettingsCardBlock<String>(
                title: l10n.settingsLanguageTitle,
                value: state.language,
                items: AppLocalizations.supportedLocales.map(
                  (locale) {
                    final languageCode = '${locale.languageCode}_'
                        '${locale.languageCode.toUpperCase()}';
                    return DropdownMenuItem<String>(
                      value: languageCode,
                      child: Text(
                        _getLanguageName(locale, l10n),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    unawaited(
                      context.read<AppCubit>().changeLanguage(
                            language: value,
                          ),
                    );
                  }
                },
              ),
              SettingsCardBlock<String>(
                title: l10n.settingsThemeTitle,
                value: state.theme,
                items: [
                  DropdownMenuItem<String>(
                    value: 'LIGHT',
                    child: Row(
                      spacing: 12,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedSun03,
                          size: 20,
                          strokeWidth: 2,
                        ),
                        Text(
                          l10n.settingsThemeLight,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'DARK',
                    child: Row(
                      spacing: 12,
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedMoon02,
                          size: 20,
                          strokeWidth: 2,
                        ),
                        Text(
                          l10n.settingsThemeDark,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    unawaited(
                      context.read<AppCubit>().changeTheme(theme: value),
                    );
                  }
                },
              ),
              SettingsCardBlock<String>(
                title: l10n.settingsBaseColorTitle,
                value: state.baseColor,
                items: ColorHelper.colorMap.entries.map(
                  (entry) {
                    final color = ColorHelper.getColorByName(entry.key);
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getColorName(entry.key, l10n),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    unawaited(
                      context.read<AppCubit>().changeBaseColor(
                            baseColor: value,
                          ),
                    );
                  }
                },
              ),
              SettingsCardBlock<String>(
                title: l10n.settingsFontTitle,
                value: state.fontFamily,
                items: AppVariables.availableFonts.entries.map(
                  (entry) {
                    return DropdownMenuItem<String>(
                      value: entry.value,
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: entry.value,
                            ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    unawaited(
                      context.read<AppCubit>().changeFontFamily(
                            fontFamily: value,
                          ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
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
