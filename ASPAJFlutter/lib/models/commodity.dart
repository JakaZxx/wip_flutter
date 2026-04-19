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
    int? parseTahun(Map<String, dynamic> json) {
      if (json['tahun'] == null) return null;
      final val = json['tahun'].toString().trim();
      if (val.isEmpty) return null;
      return int.tryParse(val) ?? int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
    }

    double? parseHarga(Map<String, dynamic> json) {
      if (json['harga_satuan'] == null) return null;
      final val = json['harga_satuan'].toString().trim();
      if (val.isEmpty) return null;
      return double.tryParse(val) ?? double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), ''));
    }

    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      return DateTime.tryParse(date.toString());
    }

    return Commodity(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Name',
      code: json['code'],
      stock: json['stock'] ?? 0,
      jurusan: json['jurusan'],
      lokasi: json['lokasi'],
      condition: json['condition'],
      photoUrl: json['photo_url'],
      merk: json['merk'],
      sumber: json['sumber'],
      tahun: parseTahun(json),
      deskripsi: json['deskripsi'],
      hargaSatuan: parseHarga(json),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
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
