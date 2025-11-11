import 'package:hive/hive.dart';
import 'package:omni_remote/app/models/models.dart';

part 'group_model.g.dart';

@HiveType(typeId: 2)
class GroupModel {
  GroupModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.devices = const <DeviceModel>[],
  });

  @HiveField(0, defaultValue: '')
  final String id;

  @HiveField(1, defaultValue: '')
  final String title;

  @HiveField(2, defaultValue: '')
  final String subtitle;

  @HiveField(3, defaultValue: '')
  final String icon;

  @HiveField(4, defaultValue: <DeviceModel>[])
  final List<DeviceModel> devices;

  GroupModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? icon,
    List<DeviceModel>? devices,
  }) {
    return GroupModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      devices: devices ?? this.devices,
    );
  }
}
