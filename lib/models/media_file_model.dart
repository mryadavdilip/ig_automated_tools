import 'package:hive/hive.dart';

part 'media_file_model.g.dart';

@HiveType(typeId: 0)
class MediaFileModel {
  @HiveField(0)
  final String path;

  @HiveField(1)
  final String? thumbnail;

  @HiveField(2)
  final int? duration;

  @HiveField(3)
  final SharedMediaType type;

  @HiveField(4)
  final String? mimeType;

  /// Post message iOS ONLY
  @HiveField(5)
  final String? message;

  MediaFileModel({
    required this.path,
    required this.type,
    this.thumbnail,
    this.duration,
    this.mimeType,
    this.message,
  });

  String get name => path.split('/').last;

  MediaFileModel.fromMap(Map<String, dynamic> json)
    : path = json['path'],
      thumbnail = json['thumbnail'],
      duration = json['duration'],
      type = SharedMediaType.fromValue(json['type']),
      mimeType = json['mimeType'],
      message = json['message'];

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'thumbnail': thumbnail,
      'duration': duration,
      'type': type.value,
      'mimeType': mimeType,
      'message': message,
    };
  }
}

@HiveType(typeId: 1)
enum SharedMediaType {
  @HiveField(0)
  image('image'),
  @HiveField(1)
  video('video'),
  @HiveField(2)
  text('text'),
  @HiveField(3)
  file('file'),
  @HiveField(4)
  url('url');

  final String value;

  const SharedMediaType(this.value);

  static SharedMediaType fromValue(String value) {
    return SharedMediaType.values.firstWhere((e) => e.value == value);
  }
}
