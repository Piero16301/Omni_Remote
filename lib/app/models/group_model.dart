import 'package:hive/hive.dart';

part 'group_model.g.dart';

/// Model representing a group of devices
@HiveType(typeId: 2)
class GroupModel {
  /// Constructor for GroupModel
  GroupModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.id = '',
  });

  /// Unique identifier for the group
  @HiveField(0, defaultValue: '')
  final String id;

  /// Title of the group
  @HiveField(1, defaultValue: '')
  final String title;

  /// Subtitle of the group
  @HiveField(2, defaultValue: '')
  final String subtitle;

  /// Icon representing the group
  @HiveField(3, defaultValue: '')
  final String icon;

  /// Creates a copy of the current GroupModel with optional new values
  GroupModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? icon,
  }) {
    return GroupModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
    );
  }
}
