import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/app/app.dart';
import 'package:user_api/user_api.dart';
import 'package:user_repository/user_repository.dart';

part 'modify_device_state.dart';

class ModifyDeviceCubit extends Cubit<ModifyDeviceState> {
  ModifyDeviceCubit(this.userRepository) : super(const ModifyDeviceState());

  final UserRepository userRepository;

  void deviceReceived(DeviceModel? device) {
    emit(
      state.copyWith(
        title: device?.title,
        subtitle: device?.subtitle,
        icon: device?.icon,
        tileType: device?.tileType,
        rangeMin: device?.rangeMin,
        rangeMax: device?.rangeMax,
        divisions: device?.divisions,
        interval: device?.interval,
        deviceModel: device,
        selectedGroupId: device?.groupId,
      ),
    );
  }

  void changeTitle(String title) {
    emit(state.copyWith(title: title));
  }

  void changeSubtitle(String subtitle) {
    emit(state.copyWith(subtitle: subtitle));
  }

  void changeIcon(String icon) {
    emit(state.copyWith(icon: icon));
  }

  void changeTileType(DeviceTileType tileType) {
    emit(state.copyWith(tileType: tileType));
  }

  void changeRangeMin(double rangeMin) {
    emit(state.copyWith(rangeMin: rangeMin));
  }

  void changeRangeMax(double rangeMax) {
    emit(state.copyWith(rangeMax: rangeMax));
  }

  void changeDivisions(int divisions) {
    emit(state.copyWith(divisions: divisions));
  }

  void changeInterval(double interval) {
    emit(state.copyWith(interval: interval));
  }

  void changeSelectedGroup(String? groupId) {
    emit(state.copyWith(selectedGroupId: groupId));
  }

  void resetSaveStatus() {
    emit(state.copyWith(saveStatus: ModifyDeviceStatus.initial));
  }

  List<GroupModel> get groups => userRepository.getGroups();

  Future<void> saveDeviceModel() async {
    if (!state.formKey.currentState!.validate()) {
      return;
    }
    emit(state.copyWith(saveStatus: ModifyDeviceStatus.loading));
    try {
      if (state.deviceModel != null) {
        final updatedDevice = state.deviceModel!.copyWith(
          id: state.deviceModel!.id,
          title: state.title,
          subtitle: state.subtitle,
          icon: state.icon,
          tileType: state.tileType,
          groupId: state.selectedGroupId,
          rangeMin: state.rangeMin,
          rangeMax: state.rangeMax,
          divisions: state.divisions,
          interval: state.interval,
        );
        await userRepository.updateDevice(device: updatedDevice);
        emit(state.copyWith(saveStatus: ModifyDeviceStatus.success));
      } else {
        final newDevice = DeviceModel(
          id: state.deviceModel?.id ?? '',
          title: state.title,
          subtitle: state.subtitle,
          icon: state.icon,
          tileType: state.tileType,
          groupId: state.selectedGroupId ?? '',
          rangeMin: state.rangeMin,
          rangeMax: state.rangeMax,
          divisions: state.divisions,
          interval: state.interval,
        );
        await userRepository.createDevice(device: newDevice);
        emit(state.copyWith(saveStatus: ModifyDeviceStatus.success));
      }
    } on Exception catch (e) {
      ModifyDeviceError modifyDeviceError;
      switch (e.toString()) {
        case 'Exception: DUPLICATE_DEVICE_NAME':
          modifyDeviceError = ModifyDeviceError.duplicateDeviceName;
        default:
          modifyDeviceError = ModifyDeviceError.unknown;
      }
      emit(
        state.copyWith(
          saveStatus: ModifyDeviceStatus.failure,
          modifyDeviceError: modifyDeviceError,
        ),
      );
    }
  }
}
