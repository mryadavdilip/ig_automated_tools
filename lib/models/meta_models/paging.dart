import 'package:hive/hive.dart';
part 'paging.g.dart';

@HiveType(typeId: 6)
class Paging {
  @HiveField(0)
  Cursors cursors;

  // Constructor
  Paging({required this.cursors});

  // Factory constructor to create Paging from JSON
  factory Paging.fromJson(json) {
    return Paging(cursors: Cursors.fromJson(json['cursors']));
  }

  // Method to convert Paging to JSON
  Map<String, dynamic> toJson() {
    return {'cursors': cursors.toJson()};
  }
}

@HiveType(typeId: 7)
class Cursors {
  @HiveField(0)
  String before;
  @HiveField(1)
  String after;

  // Constructor
  Cursors({required this.before, required this.after});

  // Factory constructor to create Cursors from JSON
  factory Cursors.fromJson(Map<String, dynamic> json) {
    return Cursors(before: json['before'], after: json['after']);
  }

  // Method to convert Cursors to JSON
  Map<String, dynamic> toJson() {
    return {'before': before, 'after': after};
  }
}
