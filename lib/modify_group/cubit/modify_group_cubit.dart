import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_remote/app/app.dart';

part 'modify_group_state.dart';

class ModifyGroupCubit extends Cubit<ModifyGroupState> {
  ModifyGroupCubit() : super(const ModifyGroupState());

  void changeTitle(String title) {
    emit(state.copyWith(title: title));
  }

  void changeSubtitle(String subtitle) {
    emit(state.copyWith(subtitle: subtitle));
  }

  void changeIcon(String icon) {
    emit(state.copyWith(icon: icon));
  }
}
