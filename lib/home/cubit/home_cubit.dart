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

  Future<void> toggleGroupEnabled(GroupModel group) async {
    final updatedGroup = group.copyWith(enabled: !group.enabled);
    await userRepository.updateGroup(group: updatedGroup);
  }

  Future<void> deleteGroup(GroupModel group) async {
    await userRepository.deleteGroup(groupId: group.id);
  }
}
