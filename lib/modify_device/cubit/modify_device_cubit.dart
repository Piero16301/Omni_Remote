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

  void resetSaveStatus() {
    emit(state.copyWith(saveStatus: ModifyDeviceStatus.initial));
  }

  Future<void> saveDeviceModel() async {
    if (!state.formKey.currentState!.validate()) {
      return;
    }
    emit(state.copyWith(saveStatus: ModifyDeviceStatus.loading));
    try {
      // TODO: Implement save logic
    } on Exception {
      emit(
        state.copyWith(
          saveStatus: ModifyDeviceStatus.failure,
          modifyDeviceError: ModifyDeviceError.unknown,
        ),
      );
    }
  }
}
