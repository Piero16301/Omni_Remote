import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_device/cubit/modify_device_cubit.dart';
import 'package:omni_remote/modify_device/widgets/widgets.dart';
import 'package:user_api/user_api.dart';

class ModifyDeviceView extends StatelessWidget {
  const ModifyDeviceView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ModifyDeviceCubit, ModifyDeviceState>(
      listener: (context, state) {
        if (state.saveStatus.isSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.modifyDeviceSaveSuccessSnackbar(state.title)),
            ),
          );
          context.pop();
        } else if (state.saveStatus.isFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                getFailureMessage(
                  error: state.modifyDeviceError,
                  title: state.title,
                  selectedGroupId: state.selectedGroupId ?? '',
                  l10n: l10n,
                  groups: context.read<ModifyDeviceCubit>().groups,
                ),
              ),
            ),
          );
          context.read<ModifyDeviceCubit>().resetSaveStatus();
        }
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            state.deviceModel == null
                ? l10n.modifyDevicePageTitleCreate
                : l10n.modifyDevicePageTitleEdit,
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
        body: Form(
          key: state.formKey,
          child: ListView(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 12,
              bottom: 120,
            ),
            children: [
              AppTextField(
                initialValue: state.title,
                onChanged: context.read<ModifyDeviceCubit>().changeTitle,
                labelText: l10n.modifyDeviceTitleLabel,
                hintText: l10n.modifyDeviceTitleHint,
                prefixIcon: HugeIcons.strokeRoundedBookmark01,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.modifyDeviceTitleErrorEmpty;
                  }
                  final alphanumericRegex = RegExp(
                    r'^[a-zA-Z0-9áéíóúÁÉÍÓÚüÜñÑ\s]+$',
                  );
                  if (!alphanumericRegex.hasMatch(value)) {
                    return l10n.modifyDeviceTitleErrorInvalidFormat;
                  }
                  if (value.contains(RegExp(r'\s{2,}'))) {
                    return l10n.modifyDeviceTitleErrorMultipleSpaces;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                initialValue: state.subtitle,
                onChanged: context.read<ModifyDeviceCubit>().changeSubtitle,
                labelText: l10n.modifyDeviceSubtitleLabel,
                hintText: l10n.modifyDeviceSubtitleHint,
                prefixIcon: HugeIcons.strokeRoundedNote,
              ),
              const SizedBox(height: 16),
              GroupSelector(
                groups: context.read<ModifyDeviceCubit>().groups,
                selectedGroupId: state.selectedGroupId,
                onGroupSelected: context
                    .read<ModifyDeviceCubit>()
                    .changeSelectedGroup,
              ),
              const SizedBox(height: 24),
              AppIconSelector(
                iconOptions: IconHelper.deviceIcons,
                selectedIcon: state.icon,
                onIconSelected: context.read<ModifyDeviceCubit>().changeIcon,
                label: l10n.modifyDeviceSelectIcon,
              ),
              const SizedBox(height: 24),
              TileTypeSelector(
                selectedType: state.tileType,
                onTypeSelected: context
                    .read<ModifyDeviceCubit>()
                    .changeTileType,
              ),
              if (state.tileType == DeviceTileType.number) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.modifyDeviceRangeConfigurationLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Expanded(
                      child: AppTextField(
                        initialValue: state.rangeMin.toString(),
                        onChanged: (value) {
                          final doubleValue = double.tryParse(value);
                          if (doubleValue != null) {
                            context.read<ModifyDeviceCubit>().changeRangeMin(
                              doubleValue,
                            );
                          }
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        labelText: l10n.modifyDeviceRangeMinLabel,
                        hintText: l10n.modifyDeviceRangeMinHint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.modifyDeviceRangeErrorEmpty;
                          }
                          final doubleValue = double.tryParse(value);
                          if (doubleValue == null) {
                            return l10n.modifyDeviceRangeErrorInvalid;
                          }
                          if (doubleValue >= state.rangeMax) {
                            return l10n.modifyDeviceRangeMinMaxError;
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      child: AppTextField(
                        initialValue: state.rangeMax.toString(),
                        onChanged: (value) {
                          final doubleValue = double.tryParse(value);
                          if (doubleValue != null) {
                            context.read<ModifyDeviceCubit>().changeRangeMax(
                              doubleValue,
                            );
                          }
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        labelText: l10n.modifyDeviceRangeMaxLabel,
                        hintText: l10n.modifyDeviceRangeMaxHint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.modifyDeviceRangeErrorEmpty;
                          }
                          final doubleValue = double.tryParse(value);
                          if (doubleValue == null) {
                            return l10n.modifyDeviceRangeErrorInvalid;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Expanded(
                      child: AppTextField(
                        initialValue: state.divisions.toString(),
                        onChanged: (value) {
                          final intValue = int.tryParse(value);
                          if (intValue != null) {
                            context.read<ModifyDeviceCubit>().changeDivisions(
                              intValue,
                            );
                          }
                        },
                        keyboardType: TextInputType.number,
                        labelText: l10n.modifyDeviceDivisionsLabel,
                        hintText: l10n.modifyDeviceDivisionsHint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.modifyDeviceRangeErrorEmpty;
                          }
                          final intValue = int.tryParse(value);
                          if (intValue == null) {
                            return l10n.modifyDeviceRangeErrorInvalid;
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      child: AppTextField(
                        initialValue: state.interval.toString(),
                        onChanged: (value) {
                          final doubleValue = double.tryParse(value);
                          if (doubleValue != null) {
                            context.read<ModifyDeviceCubit>().changeInterval(
                              doubleValue,
                            );
                          }
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        labelText: l10n.modifyDeviceIntervalLabel,
                        hintText: l10n.modifyDeviceIntervalHint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.modifyDeviceRangeErrorEmpty;
                          }
                          final doubleValue = double.tryParse(value);
                          if (doubleValue == null) {
                            return l10n.modifyDeviceRangeErrorInvalid;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 48),
              DevicePreview(
                title: state.title,
                subtitle: state.subtitle,
                iconName: state.icon,
                tileType: state.tileType,
                rangeMin: state.rangeMin,
                rangeMax: state.rangeMax,
                divisions: state.divisions,
                interval: state.interval,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: context.read<ModifyDeviceCubit>().saveDeviceModel,
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedFloppyDisk,
            size: 28,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  String getFailureMessage({
    required ModifyDeviceError error,
    required String title,
    required String selectedGroupId,
    required AppLocalizations l10n,
    required List<GroupModel> groups,
  }) {
    final group = groups.firstWhere(
      (g) => g.id == selectedGroupId,
      orElse: () => GroupModel(
        title: '',
        subtitle: '',
        icon: '',
        enabled: true,
      ),
    );
    switch (error) {
      case ModifyDeviceError.duplicateDeviceName:
        return l10n.modifyDeviceSaveDuplicateError(title, group.title);
      case ModifyDeviceError.unknown:
        return l10n.modifyDeviceSaveDefaultError(title);
      case ModifyDeviceError.none:
        return '';
    }
  }
}
