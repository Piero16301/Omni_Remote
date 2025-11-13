// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

/// A [TypeAdapter] for the [GroupModel] class.
class GroupModelAdapter extends TypeAdapter<GroupModel> {
  @override
  final int typeId = 2;

  @override
  GroupModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupModel(
      title: fields[1] == null ? '' : fields[1] as String,
      subtitle: fields[2] == null ? '' : fields[2] as String,
      icon: fields[3] == null ? '' : fields[3] as String,
      enabled: fields[4] == null || fields[4] as bool,
      id: fields[0] == null ? 0 : fields[0] as int,
      devices: fields[5] == null ? [] : (fields[5] as List).cast<DeviceModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.enabled)
      ..writeByte(5)
      ..write(obj.devices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
