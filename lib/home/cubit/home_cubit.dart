import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:user_api/user_api.dart';
import 'package:user_repository/user_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.userRepository) : super(const HomeState());

  final UserRepository userRepository;

  ValueListenable<Box<GroupModel>> getGroupsListenable() {
    return userRepository.getGroupsListenable();
  }

  ValueListenable<Box<DeviceModel>> getDevicesListenable() {
    return userRepository.getDevicesListenable();
  }

  void resetDeleteGroupStatus() {
    emit(state.copyWith(deleteGroupStatus: HomeStatus.initial));
  }

  void resetDeleteDeviceStatus() {
    emit(state.copyWith(deleteDeviceStatus: HomeStatus.initial));
  }

  Future<void> deleteGroup(GroupModel group) async {
    emit(state.copyWith(deleteGroupStatus: HomeStatus.loading));
    try {
      await userRepository.deleteGroup(groupId: group.id);
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

  Future<void> deleteDevice(DeviceModel device) async {
    emit(state.copyWith(deleteDeviceStatus: HomeStatus.loading));
    try {
      await userRepository.deleteDevice(deviceId: device.id);
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
