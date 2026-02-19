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
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: 120,
            ),
            children: const [
              Row(
                spacing: 12,
                children: [
                  LocaleSettingsCard(),
                  ThemeSettingsCard(),
                ],
              ),
              SizedBox(height: 12),
              ColorSettingsCard(),
              SizedBox(height: 12),
              FontSettingsCard(),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 12),
              SettingsAppSpecs(),
            ],
          ),
        );
      },
    );
  }
}

class LocaleSettingsCard extends StatelessWidget {
  const LocaleSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppCubit>().state;

    return SettingsCardBlock<Locale>(
      isExpanded: true,
      title: l10n.settingsLanguageTitle,
      value: state.language,
      items: AppVariables.supportedLocales.map(
        (locale) {
          return DropdownMenuItem<Locale>(
            value: locale,
            child: Text(
              _getLanguageName(locale, l10n),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        },
      ).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<AppCubit>().changeLanguage(language: value);
        }
      },
    );
  }

  String _getLanguageName(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'en':
        return l10n.settingsLanguageEnglish;
      case 'es':
        return l10n.settingsLanguageSpanish;
      case 'it':
        return l10n.settingsLanguageItalian;
      default:
        return locale.languageCode;
    }
  }
}

class ThemeSettingsCard extends StatelessWidget {
  const ThemeSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppCubit>().state;

    return SettingsCardBlock<ThemeMode>(
      isExpanded: true,
      title: l10n.settingsThemeTitle,
      value: state.theme,
      items: ThemeMode.values.map(
        (themeMode) {
          return DropdownMenuItem<ThemeMode>(
            value: themeMode,
            child: Row(
              spacing: 12,
              children: [
                HugeIcon(
                  icon: themeMode == ThemeMode.light
                      ? HugeIcons.strokeRoundedSun03
                      : (themeMode == ThemeMode.dark
                          ? HugeIcons.strokeRoundedMoon02
                          : HugeIcons.strokeRoundedFan01),
                  size: 20,
                  strokeWidth: 2,
                ),
                Text(
                  _getThemeName(themeMode, l10n),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<AppCubit>().changeTheme(theme: value);
        }
      },
    );
  }

  String _getThemeName(ThemeMode themeMode, AppLocalizations l10n) {
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.settingsThemeLight;
      case ThemeMode.dark:
        return l10n.settingsThemeDark;
      case ThemeMode.system:
        return l10n.settingsThemeSystem;
    }
  }
}

class ColorSettingsCard extends StatelessWidget {
  const ColorSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppCubit>().state;

    return SettingsCardBlock<Color>(
      title: l10n.settingsBaseColorTitle,
      value: state.baseColor,
      items: ColorHelper.colorMap.entries.map(
        (entry) {
          return DropdownMenuItem<Color>(
            value: entry.value,
            child: Row(
              spacing: 12,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Text(
                  _getColorName(entry.key, l10n),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ).toList(),
      onChanged: (value) {
        if (value != null) {
          context.read<AppCubit>().changeBaseColor(baseColor: value);
        }
      },
    );
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

class FontSettingsCard extends StatelessWidget {
  const FontSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppCubit>().state;

    final fontItems = AppVariables.availableFonts.entries.map(
      (entry) {
        return DropdownMenuItem<String>(
          value: entry.value,
          child: Text(
            entry.key,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: entry.value,
                ),
          ),
        );
      },
    ).toList();

    final validValue = fontItems.any((item) => item.value == state.fontFamily)
        ? state.fontFamily
        : (AppVariables.availableFonts[state.fontFamily] ??
            fontItems.firstOrNull?.value ??
            state.fontFamily);

    return SettingsCardBlock<String>(
      title: l10n.settingsFontTitle,
      value: validValue,
      items: fontItems,
      onChanged: (value) {
        if (value != null) {
          context.read<AppCubit>().changeFontFamily(fontFamily: value);
        }
      },
    );
  }
}
