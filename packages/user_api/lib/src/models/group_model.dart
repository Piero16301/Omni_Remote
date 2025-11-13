import 'package:hive/hive.dart';
import 'package:user_api/src/models/models.dart';

part 'group_model.g.dart';

/// Model representing a group of devices
@HiveType(typeId: 2)
class GroupModel {
  /// Constructor for GroupModel
  GroupModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    this.id = 0,
    this.devices = const <DeviceModel>[],
  });

  /// Unique identifier for the group
  @HiveField(0, defaultValue: 0)
  final int id;

  /// Title of the group
  @HiveField(1, defaultValue: '')
  final String title;

  /// Subtitle of the group
  @HiveField(2, defaultValue: '')
  final String subtitle;

  /// Icon representing the group
  @HiveField(3, defaultValue: '')
  final String icon;

  /// Indicates if the group is enabled
  @HiveField(4, defaultValue: true)
  final bool enabled;

  /// List of devices in the group
  @HiveField(5, defaultValue: <DeviceModel>[])
  final List<DeviceModel> devices;

  /// Creates a copy of the current GroupModel with optional new values
  GroupModel copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? icon,
    bool? enabled,
    List<DeviceModel>? devices,
  }) {
    return GroupModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      enabled: enabled ?? this.enabled,
      devices: devices ?? this.devices,
    );
  }
}
