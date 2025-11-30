// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String?,
      height: fields[1] as double,
      initialWeight: fields[2] as double,
      gender: fields[3] as String,
      age: fields[4] as int,
      activityLevel: fields[5] as String,
      createdAt: fields[6] as DateTime?,
      updatedAt: fields[7] as DateTime?,
      clothingColors: (fields[8] as Map?)?.cast<String, int>(),
      somatotype: fields[9] as String?,
      bodyShape: fields[10] as String?,
      personalityTraits: (fields[11] as Map?)?.cast<String, int>(),
      bodyCompositionData: (fields[12] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.height)
      ..writeByte(2)
      ..write(obj.initialWeight)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.activityLevel)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.clothingColors)
      ..writeByte(9)
      ..write(obj.somatotype)
      ..writeByte(10)
      ..write(obj.bodyShape)
      ..writeByte(11)
      ..write(obj.personalityTraits)
      ..writeByte(12)
      ..write(obj.bodyCompositionData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
