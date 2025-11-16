part of 'modify_group_cubit.dart';

enum ModifyGroupStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == ModifyGroupStatus.initial;
  bool get isLoading => this == ModifyGroupStatus.loading;
  bool get isSuccess => this == ModifyGroupStatus.success;
  bool get isFailure => this == ModifyGroupStatus.failure;
}

class ModifyGroupState extends Equatable {
  const ModifyGroupState({
    this.title = '',
    this.subtitle = '',
    this.icon = IconHelper.getGroupFirstIcon,
    this.formKey = const GlobalObjectKey<FormState>('modify_group_form'),
    this.groupModel,
    this.saveStatus = ModifyGroupStatus.initial,
  });

  final String title;
  final String subtitle;
  final String icon;
  final GlobalKey<FormState> formKey;
  final GroupModel? groupModel;
  final ModifyGroupStatus saveStatus;

  ModifyGroupState copyWith({
    String? title,
    String? subtitle,
    String? icon,
    GlobalKey<FormState>? formKey,
    GroupModel? groupModel,
    ModifyGroupStatus? saveStatus,
  }) {
    return ModifyGroupState(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      formKey: formKey ?? this.formKey,
      groupModel: groupModel ?? this.groupModel,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  List<Object?> get props => [
    title,
    subtitle,
    icon,
    formKey,
    groupModel,
    saveStatus,
  ];
}
