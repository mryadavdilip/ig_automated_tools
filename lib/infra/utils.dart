import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;

class Utils {
  static bool isDateExpired(DateTime date) {
    return DateTime.fromMillisecondsSinceEpoch(
      date.millisecondsSinceEpoch + 86400000, // 24 hours
    ).isAfter(DateTime.now());
  }

  static String durationToHMS(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

class FileExtentions {
  static final List<String> commonVideoFileExtentions = [
    'mp4',
    'mov',
    'avi',
    'wmv',
    'webm',
    'mkv',
    'flv',
    'mpg',
  ];
  static final List<String> commonAudioFileExtentions = [
    'wav',
    'mp3',
    'aac',
    'ogg',
    'aif',
    'aiff',
    'm4a',
    'wma',
  ];
  static final List<String> commonImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'svg',
    'tif',
    'tiff',
    'bmp',
    'eps',
    'webp',
    'heic',
    'avif',
    'indd',
  ];
}
