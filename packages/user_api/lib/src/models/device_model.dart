import 'package:hive/hive.dart';

part 'device_model.g.dart';

/// Enum representing the type of device tile
@HiveType(typeId: 0)
enum DeviceTileType {
  /// A boolean type device tile
  @HiveField(0)
  boolean,

  /// A number type device tile
  @HiveField(1)
  number,
}

/// Model representing a device
@HiveType(typeId: 1)
class DeviceModel {
  /// Constructor for DeviceModel
  DeviceModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tileType,
    this.rangeMin = 0,
    this.rangeMax = 0,
    this.divisions = 0,
    this.interval = 0,
  });

  /// Unique identifier for the device
  @HiveField(0, defaultValue: '')
  final String id;

  /// Title of the device
  @HiveField(1, defaultValue: '')
  final String title;

  /// Subtitle of the device
  @HiveField(2, defaultValue: '')
  final String subtitle;

  /// Icon representing the device
  @HiveField(3, defaultValue: '')
  final String icon;

  /// Type of the device tile
  @HiveField(4, defaultValue: DeviceTileType.boolean)
  final DeviceTileType tileType;

  /// Minimum range value for number type devices
  @HiveField(5, defaultValue: 0)
  final double rangeMin;

  /// Maximum range value for number type devices
  @HiveField(6, defaultValue: 0)
  final double rangeMax;

  /// Number of divisions for number type devices
  @HiveField(7, defaultValue: 0)
  final int divisions;

  /// Interval value for number type devices
  @HiveField(8, defaultValue: 0)
  final double interval;

  /// Creates a copy of the current DeviceModel with optional new values
  DeviceModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? icon,
    DeviceTileType? tileType,
    double? rangeMin,
    double? rangeMax,
    int? divisions,
    double? interval,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      tileType: tileType ?? this.tileType,
      rangeMin: rangeMin ?? this.rangeMin,
      rangeMax: rangeMax ?? this.rangeMax,
      divisions: divisions ?? this.divisions,
      interval: interval ?? this.interval,
    );
  }
}
