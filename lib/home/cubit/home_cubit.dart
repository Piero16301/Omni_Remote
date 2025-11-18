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

  Future<void> toggleGroupEnabled(GroupModel group) async {
    final updatedGroup = group.copyWith(enabled: !group.enabled);
    await userRepository.updateGroup(group: updatedGroup);
  }

  void resetDeleteStatus() {
    emit(state.copyWith(deleteStatus: HomeStatus.initial));
  }

  Future<void> deleteGroup(GroupModel group) async {
    emit(state.copyWith(deleteStatus: HomeStatus.loading));
    try {
      await userRepository.deleteGroup(groupId: group.id);
      emit(state.copyWith(deleteStatus: HomeStatus.success));
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
          deleteStatus: HomeStatus.failure,
          groupDeleteError: groupDeleteError,
        ),
      );
    }
  }
}
