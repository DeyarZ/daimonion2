// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification_service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GamificationStatsAdapter extends TypeAdapter<GamificationStats> {
  @override
  final int typeId = 1;

  @override
  GamificationStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GamificationStats(
      xp: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GamificationStats obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.xp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GamificationStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
