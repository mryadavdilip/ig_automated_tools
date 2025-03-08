// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_ai_key_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OpenAIKeyModelAdapter extends TypeAdapter<OpenAIKeyModel> {
  @override
  final int typeId = 2;

  @override
  OpenAIKeyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OpenAIKeyModel(
      key: fields[0] as String,
      lastUsed: fields[1] as DateTime,
      shouldUse: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OpenAIKeyModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.lastUsed)
      ..writeByte(2)
      ..write(obj.shouldUse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenAIKeyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
