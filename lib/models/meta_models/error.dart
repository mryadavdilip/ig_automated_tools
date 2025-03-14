// To parse this JSON data, do
//
//     final error = errorFromJson(jsonString);

import 'dart:convert';

Error errorFromJson(String str) => Error.fromJson(json.decode(str));

String errorToJson(Error data) => json.encode(data.toJson());

class Error {
  ErrorClass error;

  Error({required this.error});

  factory Error.fromJson(Map<String, dynamic> json) =>
      Error(error: ErrorClass.fromJson(json["error"]));

  Map<String, dynamic> toJson() => {"error": error.toJson()};
}

class ErrorClass {
  String message;
  String type;
  int code;
  int errorSubcode;
  String fbtraceId;

  ErrorClass({
    required this.message,
    required this.type,
    required this.code,
    required this.errorSubcode,
    required this.fbtraceId,
  });

  factory ErrorClass.fromJson(Map<String, dynamic> json) => ErrorClass(
    message: json["message"],
    type: json["type"],
    code: json["code"],
    errorSubcode: json["error_subcode"],
    fbtraceId: json["fbtrace_id"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "type": type,
    "code": code,
    "error_subcode": errorSubcode,
    "fbtrace_id": fbtraceId,
  };
}
