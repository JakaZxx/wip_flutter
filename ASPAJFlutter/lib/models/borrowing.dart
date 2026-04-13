import 'borrowing_item.dart';
import 'student.dart';
import 'user.dart';

class Borrowing {
  final int id;
  final int studentId;
  final DateTime borrowDate;
  final String? borrowTime;
  final DateTime? returnDate;
  final String? returnTime;
  final String status;
  final String? tujuan;
  final String? returnCondition;
  final String? returnPhoto;
  final int? returnedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<BorrowingItem> items;
  final Student? student;
  final User? returnedByUser;

  Borrowing({
    required this.id,
    required this.studentId,
    required this.borrowDate,
    this.borrowTime,
    this.returnDate,
    this.returnTime,
    required this.status,
    this.tujuan,
    this.returnCondition,
    this.returnPhoto,
    this.returnedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.student,
    this.returnedByUser,
  });

  factory Borrowing.fromJson(Map<String, dynamic> json) {
    return Borrowing(
      id: json['id'],
      studentId: json['student_id'] ?? (json['student'] != null ? json['student']['id'] : 0),
      borrowDate: DateTime.parse(json['borrow_date']),
      borrowTime: json['borrow_time'],
      returnDate: json['return_date'] != null
          ? DateTime.parse(json['return_date'])
          : null,
      returnTime: json['return_time'],
      status: json['status'],
      tujuan: json['tujuan'],
      returnCondition: json['return_condition'],
      returnPhoto: json['return_photo'],
      returnedBy: json['returned_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => BorrowingItem.fromJson(item))
          .toList() ?? [],
      student: json['student'] != null ? Student.fromJson(json['student']) : null,
      returnedByUser: json['returned_by_user'] != null ? User.fromJson(json['returned_by_user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'borrow_date': borrowDate.toIso8601String(),
      'borrow_time': borrowTime,
      'return_date': returnDate?.toIso8601String(),
      'return_time': returnTime,
      'status': status,
      'tujuan': tujuan,
      'return_condition': returnCondition,
      'return_photo': returnPhoto,
      'returned_by': returnedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'student': student?.toJson(),
      'returned_by_user': returnedByUser?.toJson(),
    };
  }

  // Helper getters for template compatibility
  String get studentName => student?.name ?? '-';
  String get studentClassName => student?.schoolClassName ?? '-';
  String get returnedByUserName => returnedByUser?.name ?? student?.name ?? '-';
  String? get userName => student?.name;

  // Get return photos from items
  List<Map<String, String>> get returnPhotos {
    List<Map<String, String>> photos = [];
    for (var item in items) {
      if (item.status == 'returned' && item.returnPhoto != null && item.commodityName != null) {
        photos.add({
          'url': item.returnPhoto!,
          'name': item.commodityName!,
        });
      }
    }
    return photos;
  }

  // Copy with method for updating status
  Borrowing copyWith({
    int? id,
    int? studentId,
    DateTime? borrowDate,
    String? borrowTime,
    DateTime? returnDate,
    String? returnTime,
    String? status,
    String? tujuan,
    String? returnCondition,
    String? returnPhoto,
    int? returnedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BorrowingItem>? items,
    Student? student,
    User? returnedByUser,
  }) {
    return Borrowing(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      borrowDate: borrowDate ?? this.borrowDate,
      borrowTime: borrowTime ?? this.borrowTime,
      returnDate: returnDate ?? this.returnDate,
      returnTime: returnTime ?? this.returnTime,
      status: status ?? this.status,
      tujuan: tujuan ?? this.tujuan,
      returnCondition: returnCondition ?? this.returnCondition,
      returnPhoto: returnPhoto ?? this.returnPhoto,
      returnedBy: returnedBy ?? this.returnedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      student: student ?? this.student,
      returnedByUser: returnedByUser ?? this.returnedByUser,
    );
  }
}
