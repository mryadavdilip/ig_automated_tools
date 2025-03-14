// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:smart_gallery/models/meta_models/paging.dart';

part 'accounts.g.dart';

FBAccounts fbAccountsFromJson(String str) =>
    FBAccounts.fromJson(jsonDecode(str));

String fbAccountsToJson(FBAccounts data) => jsonEncode(data.toJson());

@HiveType(typeId: 3)
class FBAccounts {
  @HiveField(0)
  List<FBAccountData> data;
  @HiveField(1)
  Paging paging;

  FBAccounts({required this.data, required this.paging});

  factory FBAccounts.fromJson(Map<String, dynamic> json) => FBAccounts(
    data: List<FBAccountData>.from(
      json["data"].map((x) => FBAccountData.fromJson(x)),
    ),
    paging: Paging.fromJson(json["paging"]),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "paging": paging.toJson(),
  };
}

@HiveType(typeId: 4)
class FBAccountData {
  @HiveField(0)
  String accessToken;
  @HiveField(1)
  String category;
  @HiveField(2)
  List<CategoryList> categoryList;
  @HiveField(3)
  String name;
  @HiveField(4)
  String id;
  @HiveField(5)
  List<String> tasks;

  FBAccountData({
    required this.accessToken,
    required this.category,
    required this.categoryList,
    required this.name,
    required this.id,
    required this.tasks,
  });

  factory FBAccountData.fromJson(Map<String, dynamic> json) => FBAccountData(
    accessToken: json["access_token"],
    category: json["category"],
    categoryList: List<CategoryList>.from(
      json["category_list"].map((x) => CategoryList.fromJson(x)),
    ),
    name: json["name"],
    id: json["id"],
    tasks: List<String>.from(json["tasks"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "access_token": accessToken,
    "category": category,
    "category_list": List<dynamic>.from(categoryList.map((x) => x.toJson())),
    "name": name,
    "id": id,
    "tasks": List<dynamic>.from(tasks.map((x) => x)),
  };
}

@HiveType(typeId: 5)
class CategoryList {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;

  CategoryList({required this.id, required this.name});

  factory CategoryList.fromJson(json) =>
      CategoryList(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
