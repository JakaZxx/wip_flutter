import 'student.dart';

class SchoolClass {
  final int id;
  final String name;
  final String? level;
  final String? programStudy;
  final int? capacity;
  final String? description;
  final int studentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Student>? students;

  SchoolClass({
    required this.id,
    required this.name,
    this.level,
    this.programStudy,
    this.capacity,
    this.description,
    required this.studentsCount,
    required this.createdAt,
    required this.updatedAt,
    this.students,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      programStudy: json['program_study'],
      capacity: json['capacity'],
      description: json['description'],
      studentsCount: json['students_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      students: json['students'] != null
          ? (json['students'] as List).map((s) => Student.fromJson(s)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'program_study': programStudy,
      'capacity': capacity,
      'description': description,
      'students_count': studentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
