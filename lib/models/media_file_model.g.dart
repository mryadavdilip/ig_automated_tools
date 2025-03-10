// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaFileModelAdapter extends TypeAdapter<MediaFileModel> {
  @override
  final int typeId = 0;

  @override
  MediaFileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaFileModel(
      path: fields[0] as String,
      type: fields[3] as SharedFileType,
      thumbnail: fields[1] as String?,
      duration: fields[2] as int?,
      mimeType: fields[4] as String?,
      message: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MediaFileModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.thumbnail)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.mimeType)
      ..writeByte(5)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SharedFileTypeAdapter extends TypeAdapter<SharedFileType> {
  @override
  final int typeId = 1;

  @override
  SharedFileType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SharedFileType.image;
      case 1:
        return SharedFileType.video;
      case 2:
        return SharedFileType.text;
      case 3:
        return SharedFileType.file;
      case 4:
        return SharedFileType.url;
      default:
        return SharedFileType.image;
    }
  }

  @override
  void write(BinaryWriter writer, SharedFileType obj) {
    switch (obj) {
      case SharedFileType.image:
        writer.writeByte(0);
        break;
      case SharedFileType.video:
        writer.writeByte(1);
        break;
      case SharedFileType.text:
        writer.writeByte(2);
        break;
      case SharedFileType.file:
        writer.writeByte(3);
        break;
      case SharedFileType.url:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedFileTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
