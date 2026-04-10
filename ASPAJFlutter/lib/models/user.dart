import 'student.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? jurusan;
  final String? nis;
  final String approvalStatus;
  final DateTime? passwordChangedAt;
  final bool mustChangePassword;
  final String? profilePicture;
  final String? profilePictureUrl;
  final DateTime? lastSeenNotifications;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Student? student;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.jurusan,
    this.nis,
    required this.approvalStatus,
    this.passwordChangedAt,
    required this.mustChangePassword,
    this.profilePicture,
    this.profilePictureUrl,
    this.lastSeenNotifications,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.student,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      jurusan: json['jurusan'],
      nis: json['nis'],
      approvalStatus: json['approval_status'] ?? 'pending',
      passwordChangedAt: json['password_changed_at'] != null
          ? DateTime.parse(json['password_changed_at'])
          : null,
      mustChangePassword:
          json['must_change_password'] == 1 ||
          json['must_change_password'] == true,
      profilePicture: json['profile_picture'],
      profilePictureUrl: json['profile_picture_url'],
      lastSeenNotifications: json['last_seen_notifications'] != null
          ? DateTime.parse(json['last_seen_notifications'])
          : null,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      student: json['student'] != null
          ? Student.fromJson(json['student'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'jurusan': jurusan,
      'nis': nis,
      'approval_status': approvalStatus,
      'password_changed_at': passwordChangedAt?.toIso8601String(),
      'must_change_password': mustChangePassword,
      'profile_picture': profilePicture,
      'profile_picture_url': profilePictureUrl,
      'last_seen_notifications': lastSeenNotifications?.toIso8601String(),
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'student': student?.toJson(),
    };
  }

  bool get isStudent => role.toLowerCase() == 'students';
  bool get isOfficer => role.toLowerCase() == 'officers';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isApproved => approvalStatus == 'approved';
  bool get isPending => approvalStatus == 'pending';
  bool get hasChangedPassword => passwordChangedAt != null;
}
