// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FBAccountsAdapter extends TypeAdapter<FBAccounts> {
  @override
  final int typeId = 3;

  @override
  FBAccounts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FBAccounts(
      data: (fields[0] as List).cast<FBAccountData>(),
      paging: fields[1] as Paging,
    );
  }

  @override
  void write(BinaryWriter writer, FBAccounts obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.data)
      ..writeByte(1)
      ..write(obj.paging);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FBAccountsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FBAccountDataAdapter extends TypeAdapter<FBAccountData> {
  @override
  final int typeId = 4;

  @override
  FBAccountData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FBAccountData(
      accessToken: fields[0] as String,
      category: fields[1] as String,
      categoryList: (fields[2] as List).cast<CategoryList>(),
      name: fields[3] as String,
      id: fields[4] as String,
      tasks: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FBAccountData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.categoryList)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.tasks);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FBAccountDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryListAdapter extends TypeAdapter<CategoryList> {
  @override
  final int typeId = 5;

  @override
  CategoryList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryList(
      id: fields[0] as String,
      name: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
