import 'package:hive/hive.dart';
part 'open_ai_key_model.g.dart';

@HiveType(typeId: 2)
class OpenAIKeyModel {
  @HiveField(0)
  String key;
  @HiveField(1)
  DateTime lastUsed;
  @HiveField(2)
  bool shouldUse;

  OpenAIKeyModel({
    required this.key,
    required this.lastUsed,
    required this.shouldUse,
  });

  factory OpenAIKeyModel.fromMap(Map<String, dynamic> map) => OpenAIKeyModel(
    key: map['key'],
    lastUsed: DateTime.fromMillisecondsSinceEpoch(map['lastUsed'] ?? 0),
    shouldUse: map['shouldUse'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'key': key,
    'lastUsed': lastUsed.millisecondsSinceEpoch,
    'shouldUse': shouldUse,
  };
}
