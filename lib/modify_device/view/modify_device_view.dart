import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/app.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:omni_remote/modify_device/cubit/modify_device_cubit.dart';
import 'package:omni_remote/modify_device/widgets/widgets.dart';

class ModifyDeviceView extends StatelessWidget {
  const ModifyDeviceView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<ModifyDeviceCubit, ModifyDeviceState>(
      listener: (context, state) {
        if (state.saveStatus.isSuccess) {
          AppFunctions.showSnackBar(
            context,
            message: l10n.modifyDeviceSaveSuccessSnackbar(state.title),
            type: SnackBarType.success,
          );
          context.pop();
        } else if (state.saveStatus.isFailure) {
          AppFunctions.showSnackBar(
            context,
            message: getFailureMessage(
              error: state.modifyDeviceError,
              title: state.title,
              selectedGroupId: state.selectedGroupId ?? '',
              l10n: l10n,
              groups: context.read<ModifyDeviceCubit>().groups,
            ),
            type: SnackBarType.error,
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
                label: l10n.modifyDeviceTitleLabel,
                hintText: l10n.modifyDeviceTitleHint,
                prefix: const HugeIcon(
                  icon: HugeIcons.strokeRoundedBookmark01,
                  strokeWidth: 2,
                ),
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
                isRequired: false,
                onChanged: context.read<ModifyDeviceCubit>().changeSubtitle,
                label: l10n.modifyDeviceSubtitleLabel,
                hintText: l10n.modifyDeviceSubtitleHint,
                prefix: const HugeIcon(
                  icon: HugeIcons.strokeRoundedNote,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 16),
              AppDropdownField(
                label: l10n.modifyDeviceGroupLabel,
                options: context.read<ModifyDeviceCubit>().groups.map((group) {
                  return DropdownMenuItem<String>(
                    value: group.id,
                    child: Row(
                      spacing: 8,
                      children: [
                        HugeIcon(
                          icon: IconHelper.getIconByName(group.icon),
                          strokeWidth: 2,
                        ),
                        Text(group.title),
                      ],
                    ),
                  );
                }).toList(),
                selected: state.selectedGroupId,
                onChanged: (selected) => context
                    .read<ModifyDeviceCubit>()
                    .changeSelectedGroup(selected),
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
                onTypeSelected:
                    context.read<ModifyDeviceCubit>().changeTileType,
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
                        initialValue: state.deviceModel != null
                            ? state.rangeMin.toString()
                            : (state.rangeMin != 0
                                ? state.rangeMin.toString()
                                : ''),
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
                        label: l10n.modifyDeviceRangeMinLabel,
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
                        initialValue: state.rangeMax != 0
                            ? state.rangeMax.toString()
                            : '',
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
                        label: l10n.modifyDeviceRangeMaxLabel,
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
                        initialValue: state.divisions != 0
                            ? state.divisions.toString()
                            : '',
                        onChanged: (value) {
                          final intValue = int.tryParse(value);
                          if (intValue != null) {
                            context.read<ModifyDeviceCubit>().changeDivisions(
                                  intValue,
                                );
                          }
                        },
                        keyboardType: TextInputType.number,
                        label: l10n.modifyDeviceDivisionsLabel,
                        hintText: l10n.modifyDeviceDivisionsHint,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.modifyDeviceRangeErrorEmpty;
                          }
                          final intValue = int.tryParse(value);
                          if (intValue == null) {
                            return l10n.modifyDeviceRangeErrorInvalid;
                          }
                          if (intValue <= 0) {
                            return l10n.modifyDeviceRangeErrorInvalid;
                          }
                          return null;
                        },
                      ),
                    ),
                    Expanded(
                      child: AppTextField(
                        initialValue: state.interval != 0
                            ? state.interval.toString()
                            : '',
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
                        label: l10n.modifyDeviceIntervalLabel,
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
              if (state.selectedGroupId != null && state.title.isNotEmpty)
                const SizedBox(height: 48),
              if (state.selectedGroupId != null && state.title.isNotEmpty)
                MqttTopicsInfo(
                  topicInfoType: TopicInfoType.device,
                  groupTitle: context
                      .read<ModifyDeviceCubit>()
                      .groups
                      .firstWhere(
                        (g) => g.id == state.selectedGroupId,
                        orElse: () => GroupModel(
                          title: '',
                          subtitle: '',
                          icon: '',
                        ),
                      )
                      .title,
                  deviceTitle: state.title,
                  deviceTileType: state.tileType,
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
      ),
    );
    switch (error) {
      case ModifyDeviceError.noGroupSelected:
        return l10n.modifyDeviceSaveNoGroupSelectedError;
      case ModifyDeviceError.duplicateDeviceName:
        return l10n.modifyDeviceSaveDuplicateError(title, group.title);
      case ModifyDeviceError.unknown:
        return l10n.modifyDeviceSaveDefaultError(title);
      case ModifyDeviceError.none:
        return '';
    }
  }
}
