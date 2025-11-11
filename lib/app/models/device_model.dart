import 'package:hive/hive.dart';

part 'device_model.g.dart';

@HiveType(typeId: 0)
enum DeviceTileType {
  @HiveField(0)
  boolean,
  @HiveField(1)
  number,
}

@HiveType(typeId: 1)
class DeviceModel {
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

  @HiveField(0, defaultValue: '')
  final String id;

  @HiveField(1, defaultValue: '')
  final String title;

  @HiveField(2, defaultValue: '')
  final String subtitle;

  @HiveField(3, defaultValue: '')
  final String icon;

  @HiveField(4, defaultValue: DeviceTileType.boolean)
  final DeviceTileType tileType;

  @HiveField(5, defaultValue: 0)
  final double rangeMin;

  @HiveField(6, defaultValue: 0)
  final double rangeMax;

  @HiveField(7, defaultValue: 0)
  final int divisions;

  @HiveField(8, defaultValue: 0)
  final double interval;

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
