// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_composition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyCompositionAdapter extends TypeAdapter<BodyComposition> {
  @override
  final int typeId = 1;

  @override
  BodyComposition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyComposition(
      muscleType: fields[0] as String,
      fatGainPattern: (fields[1] as Map).cast<String, int>(),
      fatLossPattern: (fields[2] as Map).cast<String, int>(),
      currentBodyFat: (fields[3] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, BodyComposition obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.muscleType)
      ..writeByte(1)
      ..write(obj.fatGainPattern)
      ..writeByte(2)
      ..write(obj.fatLossPattern)
      ..writeByte(3)
      ..write(obj.currentBodyFat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyCompositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
