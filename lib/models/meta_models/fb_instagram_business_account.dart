// To parse this JSON data, do
//
//     final fbInstagramBusinessAccount = fbInstagramBusinessAccountFromJson(jsonString);

import 'dart:convert';

import 'package:hive/hive.dart';

part 'fb_instagram_business_account.g.dart';

FbInstagramBusinessAccount fbInstagramBusinessAccountFromJson(String str) =>
    FbInstagramBusinessAccount.fromJson(json.decode(str));

String fbInstagramBusinessAccountToJson(FbInstagramBusinessAccount data) =>
    json.encode(data.toJson());

@HiveType(typeId: 8)
class FbInstagramBusinessAccount {
  @HiveField(0)
  InstagramBusinessAccount instagramBusinessAccount;
  @HiveField(1)
  String id;

  FbInstagramBusinessAccount({
    required this.instagramBusinessAccount,
    required this.id,
  });

  factory FbInstagramBusinessAccount.fromJson(Map<String, dynamic> json) =>
      FbInstagramBusinessAccount(
        instagramBusinessAccount: InstagramBusinessAccount.fromJson(
          json["instagram_business_account"],
        ),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
    "instagram_business_account": instagramBusinessAccount.toJson(),
    "id": id,
  };
}

@HiveType(typeId: 9)
class InstagramBusinessAccount {
  @HiveField(0)
  String id;

  InstagramBusinessAccount({required this.id});

  factory InstagramBusinessAccount.fromJson(Map<String, dynamic> json) =>
      InstagramBusinessAccount(id: json["id"]);

  Map<String, dynamic> toJson() => {"id": id};
}
