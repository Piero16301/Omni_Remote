part of 'modify_device_cubit.dart';

enum ModifyDeviceStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == ModifyDeviceStatus.initial;
  bool get isLoading => this == ModifyDeviceStatus.loading;
  bool get isSuccess => this == ModifyDeviceStatus.success;
  bool get isFailure => this == ModifyDeviceStatus.failure;
}

enum ModifyDeviceError { none, duplicateDeviceId, unknown }

class ModifyDeviceState extends Equatable {
  const ModifyDeviceState({
    this.title = '',
    this.subtitle = '',
    this.icon = IconHelper.getDeviceFirstIcon,
    this.tileType = DeviceTileType.boolean,
    this.rangeMin = 0,
    this.rangeMax = 0,
    this.divisions = 0,
    this.interval = 0,
    this.formKey = const GlobalObjectKey<FormState>('modify_device_form'),
    this.deviceModel,
    this.saveStatus = ModifyDeviceStatus.initial,
    this.modifyDeviceError = ModifyDeviceError.none,
  });

  final String title;
  final String subtitle;
  final String icon;
  final DeviceTileType tileType;
  final double rangeMin;
  final double rangeMax;
  final int divisions;
  final double interval;
  final GlobalKey<FormState> formKey;
  final DeviceModel? deviceModel;
  final ModifyDeviceStatus saveStatus;
  final ModifyDeviceError modifyDeviceError;

  ModifyDeviceState copyWith({
    String? title,
    String? subtitle,
    String? icon,
    DeviceTileType? tileType,
    double? rangeMin,
    double? rangeMax,
    int? divisions,
    double? interval,
    GlobalKey<FormState>? formKey,
    DeviceModel? deviceModel,
    ModifyDeviceStatus? saveStatus,
    ModifyDeviceError? modifyDeviceError,
  }) {
    return ModifyDeviceState(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      tileType: tileType ?? this.tileType,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      divisions: divisions ?? this.divisions,
      interval: interval ?? this.interval,
      formKey: formKey ?? this.formKey,
      deviceModel: deviceModel ?? this.deviceModel,
      saveStatus: saveStatus ?? this.saveStatus,
      modifyDeviceError: modifyDeviceError ?? this.modifyDeviceError,
    );
  }

  @override
  List<Object?> get props => [
    title,
    subtitle,
    icon,
    tileType,
    rangeMin,
    rangeMax,
    divisions,
    interval,
    formKey,
    deviceModel,
    saveStatus,
    modifyDeviceError,
  ];
}
