
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
  final String studentName;
  final String itemsSummary;

  RecentRequest({required this.studentName, required this.itemsSummary});

  factory RecentRequest.fromJson(Map<String, dynamic> json) {
    return RecentRequest(
      studentName: json['student_name'] ?? 'Unknown',
      itemsSummary: json['items_summary'] ?? '',
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
  final List<RecentRequest>? newRequests;
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
    this.newRequests,
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

      // Officer
      activeBorrowingsCount: _parseInt(json['active_borrowings_count']),
      pendingRequestsCount: _parseInt(json['pending_requests_count']),
      overdueBorrowingsCount: _parseInt(json['overdue_borrowings_count']),
      rejectedBorrowingsCount: _parseInt(json['rejected_borrowings_count']),
      returnedBorrowingsCount: _parseInt(json['returned_borrowings_count']),
      newRequests: (json['new_requests'] as List<dynamic>?)
          ?.map((e) => RecentRequest.fromJson(e as Map<String, dynamic>))
          .toList(),

      // Student
      totalAvailableAssets: _parseInt(json['total_available_assets']),
      myActiveBorrowingsCount: _parseInt(json['my_active_borrowings_count']),
      pendingBorrowingsCount: _parseInt(json['pending_borrowings_count']),
      approvedOrOverdueBorrowingsCount: _parseInt(json['approved_or_overdue_borrowings_count']),
      upcomingDueBorrowing: json['upcoming_due_borrowing'] as Map<String, dynamic>?,
    );
  }
}