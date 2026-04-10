import 'commodity.dart';
import '../services/api_service.dart';

class BorrowingItem {
  // Getter for jurusan (department) from commodity
  String? get jurusan => commodity?.jurusan;
  final int? id;
  final int? borrowingId;
  final int commodityId;
  final int quantity;
  final String? status;
  final String? returnCondition;
  final String? returnPhoto;
  final String? condition;
  final String? description;
  final String? photoPath;
  final String? itemPhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? commodityName;
  final Commodity? commodity;

  BorrowingItem({
    this.id,
    this.borrowingId,
    required this.commodityId,
    required this.quantity,
    this.status,
    this.returnCondition,
    this.returnPhoto,
    this.condition,
    this.description,
    this.photoPath,
    this.itemPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.commodityName,
    this.commodity,
  });

  factory BorrowingItem.fromJson(Map<String, dynamic> json) {
    return BorrowingItem(
      id: json['id'],
      borrowingId: json['borrowing_id'] != null
          ? json['borrowing_id'] as int
          : null,
      commodityId: json['commodity_id'],
      quantity: json['quantity'],
      status: json['status'],
      returnCondition: json['return_condition'],
      returnPhoto: json['return_photo'],
      condition: json['condition'],
      description: json['description'],
      photoPath: json['photo_path'],
      itemPhotoUrl: json['photo_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      commodityName: json['commodity']?['name'],
      commodity: json['commodity'] != null
          ? Commodity.fromJson(json['commodity'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'borrowing_id': borrowingId,
      'commodity_id': commodityId,
      'quantity': quantity,
      'status': status,
      'return_condition': returnCondition,
      'return_photo': returnPhoto,
      'condition': condition,
      'description': description,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => commodityName ?? 'Item $commodityId';
  String? get photoUrl => itemPhotoUrl ?? commodity?.photoUrl ?? photoPath;
  String? get fixedPhotoUrl {
    if (photoUrl != null) {
      return ApiService.fixPhotoUrl(photoUrl);
    }
    return commodity?.fixedPhotoUrl;
  }
}
