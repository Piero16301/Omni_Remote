import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:omni_remote/app/app.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  final LocalStorageService localStorage = getIt<LocalStorageService>();

  ValueListenable<List<GroupModel>> getGroupsListenable() {
    return localStorage.getGroupsListenable();
  }

  ValueListenable<List<DeviceModel>> getDevicesListenable() {
    return localStorage.getDevicesListenable();
  }

  void resetDeleteGroupStatus() {
    emit(state.copyWith(deleteGroupStatus: HomeStatus.initial));
  }

  void resetDeleteDeviceStatus() {
    emit(state.copyWith(deleteDeviceStatus: HomeStatus.initial));
  }

  void deleteGroup(GroupModel group) {
    emit(state.copyWith(deleteGroupStatus: HomeStatus.loading));
    try {
      localStorage.deleteGroup(groupId: group.id);
      emit(state.copyWith(deleteGroupStatus: HomeStatus.success));
    } on Exception catch (e) {
      GroupDeleteError groupDeleteError;
      switch (e.toString()) {
        case 'Exception: GROUP_NOT_EMPTY':
          groupDeleteError = GroupDeleteError.groupNotEmpty;
        case 'Exception: GROUP_NOT_FOUND':
          groupDeleteError = GroupDeleteError.groupNotFound;
        default:
          groupDeleteError = GroupDeleteError.unknown;
      }
      emit(
        state.copyWith(
          deleteGroupStatus: HomeStatus.failure,
          groupDeleteError: groupDeleteError,
        ),
      );
    }
  }

  void deleteDevice(DeviceModel device) {
    emit(state.copyWith(deleteDeviceStatus: HomeStatus.loading));
    try {
      localStorage.deleteDevice(deviceId: device.id);
      emit(state.copyWith(deleteDeviceStatus: HomeStatus.success));
    } on Exception catch (e) {
      DeviceDeleteError deviceDeleteError;
      switch (e.toString()) {
        case 'Exception: DEVICE_NOT_FOUND':
          deviceDeleteError = DeviceDeleteError.deviceNotFound;
        default:
          deviceDeleteError = DeviceDeleteError.unknown;
      }
      emit(
        state.copyWith(
          deleteDeviceStatus: HomeStatus.failure,
          deviceDeleteError: deviceDeleteError,
        ),
      );
    }
  }
}
