// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paging.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PagingAdapter extends TypeAdapter<Paging> {
  @override
  final int typeId = 6;

  @override
  Paging read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Paging(
      cursors: fields[0] as Cursors,
    );
  }

  @override
  void write(BinaryWriter writer, Paging obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.cursors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PagingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CursorsAdapter extends TypeAdapter<Cursors> {
  @override
  final int typeId = 7;

  @override
  Cursors read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cursors(
      before: fields[0] as String,
      after: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Cursors obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.before)
      ..writeByte(1)
      ..write(obj.after);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursorsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
