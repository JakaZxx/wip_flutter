import 'school_class.dart';
import 'user.dart';

class Student {
  final int id;
  final String name;
  final int? schoolClassId;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SchoolClass? schoolClass;
  final User? user;

  Student({
    required this.id,
    required this.name,
    this.schoolClassId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.schoolClass,
    this.user,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      schoolClassId: json['school_class_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      schoolClass: json['school_class'] != null ? SchoolClass.fromJson(json['school_class']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'school_class_id': schoolClassId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'school_class': schoolClass?.toJson(),
      'user': user?.toJson(),
    };
  }

  String get schoolClassName => schoolClass?.name ?? '-';
  String get email => user?.email ?? '-';
  String get nis => user?.nis ?? '-';
}
