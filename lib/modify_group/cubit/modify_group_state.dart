part of 'modify_group_cubit.dart';

class ModifyGroupState extends Equatable {
  const ModifyGroupState({
    this.title = '',
    this.subtitle = '',
    this.icon = IconHelper.getGroupFirstIcon,
  });

  final String title;
  final String subtitle;
  final String icon;

  ModifyGroupState copyWith({
    String? title,
    String? subtitle,
    String? icon,
  }) {
    return ModifyGroupState(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<Object> get props => [
    title,
    subtitle,
    icon,
  ];
}
