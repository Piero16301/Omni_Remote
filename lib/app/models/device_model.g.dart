// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceModelAdapter extends TypeAdapter<DeviceModel> {
  @override
  final int typeId = 1;

  @override
  DeviceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceModel(
      id: fields[0] == null ? '' : fields[0] as String,
      title: fields[1] == null ? '' : fields[1] as String,
      subtitle: fields[2] == null ? '' : fields[2] as String,
      icon: fields[3] == null ? '' : fields[3] as String,
      tileType: fields[4] == null
          ? DeviceTileType.boolean
          : fields[4] as DeviceTileType,
      rangeMin: fields[5] == null ? 0 : fields[5] as double,
      rangeMax: fields[6] == null ? 0 : fields[6] as double,
      divisions: fields[7] == null ? 0 : fields[7] as int,
      interval: fields[8] == null ? 0 : fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.tileType)
      ..writeByte(5)
      ..write(obj.rangeMin)
      ..writeByte(6)
      ..write(obj.rangeMax)
      ..writeByte(7)
      ..write(obj.divisions)
      ..writeByte(8)
      ..write(obj.interval);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeviceTileTypeAdapter extends TypeAdapter<DeviceTileType> {
  @override
  final int typeId = 0;

  @override
  DeviceTileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeviceTileType.boolean;
      case 1:
        return DeviceTileType.number;
      default:
        return DeviceTileType.boolean;
    }
  }

  @override
  void write(BinaryWriter writer, DeviceTileType obj) {
    switch (obj) {
      case DeviceTileType.boolean:
        writer.writeByte(0);
      case DeviceTileType.number:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceTileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
