// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_entity_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AgentEntityHiveAdapter extends TypeAdapter<AgentEntityHive> {
  @override
  final int typeId = 11;

  @override
  AgentEntityHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgentEntityHive(
      agentId: fields[0] as String,
      agentName: fields[1] as String,
      agentMobile: fields[2] as String,
      registrationDate: fields[3] as DateTime,
      role: fields[4] as String,
      uid: fields[5] as String,
      email: fields[6] as String,
      photoUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AgentEntityHive obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.agentId)
      ..writeByte(1)
      ..write(obj.agentName)
      ..writeByte(2)
      ..write(obj.agentMobile)
      ..writeByte(3)
      ..write(obj.registrationDate)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.uid)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.photoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentEntityHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
