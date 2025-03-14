// To parse this JSON data, do
//
//     final contentPublishingLimit = contentPublishingLimitFromJson(jsonString);

import 'dart:convert';

ContentPublishingLimit contentPublishingLimitFromJson(String str) =>
    ContentPublishingLimit.fromJson(json.decode(str));

String contentPublishingLimitToJson(ContentPublishingLimit data) =>
    json.encode(data.toJson());

class ContentPublishingLimit {
  List<Datum> data;

  ContentPublishingLimit({required this.data});

  factory ContentPublishingLimit.fromJson(Map<String, dynamic> json) =>
      ContentPublishingLimit(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int quotaUsage;
  Config config;

  Datum({required this.quotaUsage, required this.config});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    quotaUsage: json["quota_usage"],
    config: Config.fromJson(json["config"]),
  );

  Map<String, dynamic> toJson() => {
    "quota_usage": quotaUsage,
    "config": config.toJson(),
  };
}

class Config {
  int quotaTotal;
  int quotaDuration;

  Config({required this.quotaTotal, required this.quotaDuration});

  factory Config.fromJson(Map<String, dynamic> json) => Config(
    quotaTotal: json["quota_total"],
    quotaDuration: json["quota_duration"],
  );

  Map<String, dynamic> toJson() => {
    "quota_total": quotaTotal,
    "quota_duration": quotaDuration,
  };
}
