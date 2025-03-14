// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fb_instagram_business_account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FbInstagramBusinessAccountAdapter
    extends TypeAdapter<FbInstagramBusinessAccount> {
  @override
  final int typeId = 8;

  @override
  FbInstagramBusinessAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FbInstagramBusinessAccount(
      instagramBusinessAccount: fields[0] as InstagramBusinessAccount,
      id: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FbInstagramBusinessAccount obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.instagramBusinessAccount)
      ..writeByte(1)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FbInstagramBusinessAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InstagramBusinessAccountAdapter
    extends TypeAdapter<InstagramBusinessAccount> {
  @override
  final int typeId = 9;

  @override
  InstagramBusinessAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstagramBusinessAccount(
      id: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InstagramBusinessAccount obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstagramBusinessAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
