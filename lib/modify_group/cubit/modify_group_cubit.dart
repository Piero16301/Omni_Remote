import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/app/app.dart';
import 'package:user_api/user_api.dart';
import 'package:user_repository/user_repository.dart';

part 'modify_group_state.dart';

class ModifyGroupCubit extends Cubit<ModifyGroupState> {
  ModifyGroupCubit(this.userRepository) : super(const ModifyGroupState());

  final UserRepository userRepository;

  void groupReceived(GroupModel? group) {
    emit(
      state.copyWith(
        title: group?.title,
        subtitle: group?.subtitle,
        icon: group?.icon,
        groupModel: group,
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

  void resetSaveStatus() {
    emit(state.copyWith(saveStatus: ModifyGroupStatus.initial));
  }

  Future<void> saveGroupModel() async {
    if (!state.formKey.currentState!.validate()) {
      return;
    }
    emit(state.copyWith(saveStatus: ModifyGroupStatus.loading));
    try {
      if (state.groupModel != null) {
        final updatedGroup = state.groupModel!.copyWith(
          id: state.groupModel!.id,
          title: state.title,
          subtitle: state.subtitle,
          icon: state.icon,
          enabled: state.groupModel!.enabled,
          devices: state.groupModel!.devices,
        );
        await userRepository.updateGroup(group: updatedGroup);
        emit(state.copyWith(saveStatus: ModifyGroupStatus.success));
      } else {
        final newGroup = GroupModel(
          id: state.groupModel?.id ?? 0,
          title: state.title,
          subtitle: state.subtitle,
          icon: state.icon,
          enabled: true,
        );
        await userRepository.createGroup(group: newGroup);
        emit(state.copyWith(saveStatus: ModifyGroupStatus.success));
      }
    } on Exception {
      emit(state.copyWith(saveStatus: ModifyGroupStatus.failure));
    }
  }
}
