class Utils {
  static bool isDateExpired(DateTime date) {
    return DateTime.fromMillisecondsSinceEpoch(
      date.millisecondsSinceEpoch + 86400000, // 24 hours
    ).isAfter(DateTime.now());
  }

  static String durationToHumanReadable(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
