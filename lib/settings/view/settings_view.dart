import 'package:country_flags/country_flags.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/settings/settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) =>
          previous.theme != current.theme ||
          previous.baseColor != current.baseColor ||
          previous.fontFamily != current.fontFamily ||
          previous.language != current.language,
      builder: (context, state) {
        final currentColorName = state.baseColor.localizedName(context);
        final currentThemeName = state.theme.localizedName(context);
        final currentLanguageName = state.language.localizedName(context);

        return Scaffold(
          appBar: ExpressiveTopAppBar(
            centerTitle: false,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: ExpressiveIconButton.circle(
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  strokeWidth: 2,
                ),
                onPressed: () => context.pop(),
              ),
            ),
            title: Text(
              l10n.settingsAppBarTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(top: 2, bottom: 24),
            children: [
              // Sección: Aspecto (Tema, Color base y Fuente agrupados)
              ExpressiveCardGroup(
                title: l10n.settingsAppearanceTitle,
                children: [
                  ExpressiveListTile(
                    leading: const ExpressiveBadge(
                      backgroundColor: Color(0xFF6750A4),
                      foregroundColor: Colors.white,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedMoon02,
                        strokeWidth: 2,
                      ),
                    ),
                    title: Text(l10n.settingsThemeTitle),
                    subtitle: Text(currentThemeName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: _getThemeIcon(state.theme),
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    onTap: () => _showThemePickerModal(context, state),
                  ),
                  ExpressiveListTile(
                    leading: const ExpressiveBadge(
                      backgroundColor: Color(0xFFE06D53),
                      foregroundColor: Colors.white,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedPaintBoard,
                        strokeWidth: 2,
                      ),
                    ),
                    title: Text(l10n.settingsBaseColorTitle),
                    subtitle: Text(currentColorName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: state.baseColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    onTap: () => _showColorPickerModal(context, state),
                  ),
                  ExpressiveListTile(
                    leading: const ExpressiveBadge(
                      backgroundColor: Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedTextFont,
                        strokeWidth: 2,
                      ),
                    ),
                    title: Text(l10n.settingsFontTitle),
                    subtitle: Text(
                      ExpressiveFonts.availableFonts.entries
                          .firstWhere(
                            (entry) => entry.value == state.fontFamily,
                            orElse: () =>
                                MapEntry(state.fontFamily, state.fontFamily),
                          )
                          .key,
                      style: TextStyle(fontFamily: state.fontFamily),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          child: Center(
                            child: Text(
                              'Aa',
                              style: TextStyle(
                                fontFamily: state.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    onTap: () => _showFontPickerModal(context, state),
                  ),
                ],
              ),

              // Sección: Idioma
              ExpressiveCardGroup(
                title: l10n.settingsLanguageTitle,
                children: [
                  ExpressiveListTile(
                    leading: const ExpressiveBadge(
                      backgroundColor: Color(0xFF00ACC1),
                      foregroundColor: Colors.white,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedGlobe02,
                        strokeWidth: 2,
                      ),
                    ),
                    title: Text(l10n.settingsLanguageTitle),
                    subtitle: Text(currentLanguageName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CountryFlag.fromLanguageCode(
                          state.language.languageCode,
                          theme: const ImageTheme(
                            width: 24,
                            height: 24,
                            shape: RoundedRectangle(6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight01,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    onTap: () => _showLanguagePickerModal(context, state),
                  ),
                ],
              ),

              // Sección: Información de la aplicación
              const SettingsAppSpecs(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showSettingsModal({
    required BuildContext context,
    required String title,
    required List<Widget> Function(BuildContext modalContext) itemsBuilder,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxHeight =
        MediaQuery.of(context).size.height *
        AppVariables.modalBottomSheetMaxHeightPct;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (modalContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: itemsBuilder(modalContext),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showThemePickerModal(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final options = [
      (ThemeMode.light, HugeIcons.strokeRoundedSun03),
      (ThemeMode.dark, HugeIcons.strokeRoundedMoon02),
      (ThemeMode.system, HugeIcons.strokeRoundedComputerPhoneSync),
    ];

    _showSettingsModal(
      context: context,
      title: l10n.settingsThemeTitle,
      itemsBuilder: (modalContext) => options.map((option) {
        final mode = option.$1;
        final title = mode.localizedName(modalContext);
        final icon = option.$2;
        final isSelected = state.theme == mode;

        return ListTile(
          leading: HugeIcon(
            icon: icon,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            strokeWidth: 2,
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          trailing: isSelected
              ? HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                )
              : null,
          onTap: () {
            context.read<AppCubit>().changeTheme(theme: mode);
            Navigator.pop(modalContext);
          },
        );
      }).toList(),
    );
  }

  void _showColorPickerModal(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    _showSettingsModal(
      context: context,
      title: l10n.settingsBaseColorTitle,
      itemsBuilder: (modalContext) => ExpressiveColors.palette.entries.map((
        entry,
      ) {
        final isSelected = entry.value.toARGB32() == state.baseColor.toARGB32();
        return ListTile(
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: entry.value,
              shape: BoxShape.circle,
            ),
          ),
          title: Text(entry.value.localizedName(modalContext)),
          trailing: isSelected
              ? HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                )
              : null,
          onTap: () {
            context.read<AppCubit>().changeBaseColor(baseColor: entry.value);
            Navigator.pop(modalContext);
          },
        );
      }).toList(),
    );
  }

  void _showFontPickerModal(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    _showSettingsModal(
      context: context,
      title: l10n.settingsFontTitle,
      itemsBuilder: (modalContext) =>
          ExpressiveFonts.availableFonts.entries.map((entry) {
            final isSelected = entry.value == state.fontFamily;
            return ListTile(
              leading: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Aa',
                  style: TextStyle(
                    fontFamily: entry.value,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              title: Text(
                entry.key,
                style: TextStyle(
                  fontFamily: entry.value,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              trailing: isSelected
                  ? HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      color: colorScheme.primary,
                      strokeWidth: 2,
                    )
                  : null,
              onTap: () {
                context.read<AppCubit>().changeFontFamily(
                  fontFamily: entry.value,
                );
                Navigator.pop(modalContext);
              },
            );
          }).toList(),
    );
  }

  void _showLanguagePickerModal(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    _showSettingsModal(
      context: context,
      title: l10n.selectLanguage,
      itemsBuilder: (modalContext) => ExpressiveLanguages.supportedLocales.map((
        locale,
      ) {
        final isSelected = locale.languageCode == state.language.languageCode;
        return ListTile(
          leading: CountryFlag.fromLanguageCode(
            locale.languageCode,
            theme: const ImageTheme(
              width: 28,
              height: 28,
              shape: RoundedRectangle(6),
            ),
          ),
          title: Text(locale.localizedName(modalContext)),
          trailing: isSelected
              ? HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                )
              : null,
          onTap: () {
            context.read<AppCubit>().changeLanguage(language: locale);
            Navigator.pop(modalContext);
          },
        );
      }).toList(),
    );
  }

  List<List<dynamic>> _getThemeIcon(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => HugeIcons.strokeRoundedSun03,
      ThemeMode.dark => HugeIcons.strokeRoundedMoon02,
      ThemeMode.system => HugeIcons.strokeRoundedComputerPhoneSync,
    };
  }
}
