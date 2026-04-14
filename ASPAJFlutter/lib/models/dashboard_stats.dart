
// Helper function to safely parse dynamic values to int.
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

// Helper function to safely parse dynamic values to double.
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class ChartData {
  final List<String> labels;
  final List<double> data;
  final List<double>? data2;

  ChartData({required this.labels, required this.data, this.data2});

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      labels: List<String>.from(json['labels'] ?? []),
      data: (json['data'] as List<dynamic>? ?? []).map((e) => _parseDouble(e) ?? 0.0).toList(),
      data2: (json['data2'] as List<dynamic>? ?? []).map((e) => _parseDouble(e) ?? 0.0).toList(),
    );
  }
}

class RecentRequest {
  final int id;
  final String studentName;
  final String? status;
  final DateTime? createdAt;
  final List<String> items;

  RecentRequest({
    required this.id,
    required this.studentName,
    this.status,
    this.createdAt,
    required this.items,
  });

  factory RecentRequest.fromJson(Map<String, dynamic> json) {
    var itemsList = <String>[];
    if (json['items'] != null) {
      for (var item in json['items']) {
        itemsList.add(item['commodity_name'] ?? 'Unknown');
      }
    }
    return RecentRequest(
      id: json['id'] ?? 0,
      studentName: json['student']?['user']?['name'] ?? json['student_name'] ?? 'Unknown',
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      items: itemsList,
    );
  }
}

class RecentUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final DateTime? createdAt;

  RecentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory RecentUser.fromJson(Map<String, dynamic> json) {
    return RecentUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}

class DashboardStats {
  final int? totalAssets;
  final int? totalUsers;
  final int? pendingUsersCount;
  final int? totalBorrowings;
  final ChartData? userGrowth;
  final Map<String, dynamic>? assetDistribution;
  final Map<String, dynamic>? assetStatus;
  final int? activeBorrowingsCount;
  final int? pendingRequestsCount;
  final int? overdueBorrowingsCount;
  final int? rejectedBorrowingsCount;
  final int? returnedBorrowingsCount;
  final List<RecentRequest>? recentBorrowings;
  final List<RecentUser>? recentUsers;
  final int? totalAvailableAssets;
  final int? myActiveBorrowingsCount;
  final int? pendingBorrowingsCount;
  final int? approvedOrOverdueBorrowingsCount;
  final Map<String, dynamic>? upcomingDueBorrowing;

  DashboardStats({
    this.totalAssets,
    this.totalUsers,
    this.pendingUsersCount,
    this.totalBorrowings,
    this.userGrowth,
    this.assetDistribution,
    this.assetStatus,
    this.activeBorrowingsCount,
    this.pendingRequestsCount,
    this.overdueBorrowingsCount,
    this.rejectedBorrowingsCount,
    this.returnedBorrowingsCount,
    this.recentBorrowings,
    this.recentUsers,
    this.totalAvailableAssets,
    this.myActiveBorrowingsCount,
    this.pendingBorrowingsCount,
    this.approvedOrOverdueBorrowingsCount,
    this.upcomingDueBorrowing,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      // Common
      totalAssets: _parseInt(json['total_assets']),

      // Admin
      totalUsers: _parseInt(json['total_users']),
      pendingUsersCount: _parseInt(json['pending_users_count']),
      totalBorrowings: _parseInt(json['total_borrowings']),
      userGrowth: json['user_growth'] != null ? ChartData.fromJson(json['user_growth']) : null,
      assetDistribution: json['asset_distribution'] as Map<String, dynamic>?,
      assetStatus: json['asset_status'] as Map<String, dynamic>?,
      recentUsers: (json['recent_users'] as List<dynamic>?)
          ?.map((e) => RecentUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentBorrowings: (json['recent_borrowings'] as List<dynamic>?)
          ?.map((e) => RecentRequest.fromJson(e as Map<String, dynamic>))
          .toList(),

      // Officer
      activeBorrowingsCount: _parseInt(json['active_borrowings_count']),
      pendingRequestsCount: _parseInt(json['pending_approvals_count'] ?? json['pending_requests_count']),
      overdueBorrowingsCount: _parseInt(json['overdue_borrowings_count']),
      rejectedBorrowingsCount: _parseInt(json['rejected_borrowings_count']),
      returnedBorrowingsCount: _parseInt(json['returned_borrowings_count']),

      // Student
      totalAvailableAssets: _parseInt(json['total_available_assets']),
      myActiveBorrowingsCount: _parseInt(json['my_active_borrowings_count']),
      pendingBorrowingsCount: _parseInt(json['pending_borrowings_count']),
      approvedOrOverdueBorrowingsCount: _parseInt(json['approved_or_overdue_borrowings_count']),
      upcomingDueBorrowing: json['upcoming_due_borrowing'] as Map<String, dynamic>?,
    );
  }
}