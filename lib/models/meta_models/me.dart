import 'dart:convert';

User userFromJson(json) => User.fromJson(jsonDecode(json));

class User {
  String name;
  String id;

  // Constructor
  User({required this.name, required this.id});

  // Factory constructor to create a User from JSON
  factory User.fromJson(json) {
    return User(name: json['name'], id: json['id']);
  }

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'id': id};
  }
}
