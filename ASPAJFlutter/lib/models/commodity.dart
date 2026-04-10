import '../services/api_service.dart';

class Commodity {
  final int id;
  final String name;
  final String? code;
  final int stock;
  final String? jurusan;
  final String? lokasi;
  final String? condition;
  final String? photoUrl;
  final String? merk;
  final String? sumber;
  final int? tahun;
  final String? deskripsi;
  final double? hargaSatuan;
  final DateTime createdAt;
  final DateTime updatedAt;

  String? get fixedPhotoUrl => photoUrl != null ? ApiService.fixPhotoUrl(photoUrl) : null;

  Commodity({
    required this.id,
    required this.name,
    this.code,
    required this.stock,
    this.jurusan,
    this.lokasi,
    this.condition,
    this.photoUrl, // Menggunakan photoUrl langsung dari API
    this.merk,
    this.sumber,
    this.tahun,
    this.deskripsi,
    this.hargaSatuan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Name',
      code: json['code'],
      stock: json['stock'] ?? 0,
      jurusan: json['jurusan'],
      lokasi: json['lokasi'],
      condition: json['condition'],
      photoUrl: json['photo_url'], // Memetakan photo_url dari JSON
      merk: json['merk'],
      sumber: json['sumber'],
      tahun: json['tahun'] != null ? int.parse(json['tahun'].toString()) : null,
      deskripsi: json['deskripsi'],
      hargaSatuan: json['harga_satuan'] != null
          ? double.parse(json['harga_satuan'].toString())
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'stock': stock,
      'jurusan': jurusan,
      'lokasi': lokasi,
      'condition': condition,
      'photo_url': photoUrl, // Menggunakan photoUrl untuk toJson
      'merk': merk,
      'sumber': sumber,
      'tahun': tahun,
      'deskripsi': deskripsi,
      'harga_satuan': hargaSatuan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
