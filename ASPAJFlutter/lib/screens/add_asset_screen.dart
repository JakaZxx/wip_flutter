// ignore_for_file: use_build_context_synchronously
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/commodity_provider.dart';
import '../services/api_service.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _stockController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _merkController = TextEditingController();
  final _hargaSatuanController = TextEditingController();
  final _sumberController = TextEditingController();
  final _tahunController = TextEditingController();
  final _deskripsiController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes; // store bytes for preview & web
  bool _removePhoto = false; // when user wants to remove existing photo

  String? _selectedJurusan;
  bool _isLoading = false;

  final List<String> _jurusanOptions = [
    'Rekayasa Perangkat Lunak',
    'Desain Komunikasi Visual',
    'Teknik Otomasi Industri',
    'Teknik Instalasi Tenaga Listrik',
    'Teknik Audio Video',
    'Teknik Komputer Jaringan',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _stockController.dispose();
    _lokasiController.dispose();
    _merkController.dispose();
    _hargaSatuanController.dispose();
    _sumberController.dispose();
    _tahunController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedJurusan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih jurusan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final commodityData = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'stock': int.parse(_stockController.text),
        'jurusan': _selectedJurusan,
        'lokasi': _lokasiController.text.trim(),
        'merk': _merkController.text.trim().isEmpty ? null : _merkController.text.trim(),
        'harga_satuan': _hargaSatuanController.text.trim().isEmpty ? null : double.parse(_hargaSatuanController.text),
        'sumber': _sumberController.text.trim().isEmpty ? null : _sumberController.text.trim(),
        'tahun': _tahunController.text.trim().isEmpty ? null : int.parse(_tahunController.text),
        'deskripsi': _deskripsiController.text.trim().isEmpty ? null : _deskripsiController.text.trim(),
      };

      // If user picked an image, upload it first and include returned path
      if (_pickedImageBytes != null && _pickedImage != null) {
        final uploadedPath = await ApiService().uploadBytes(_pickedImageBytes!, _pickedImage!.name, 'file');
        // Backend expects the field name 'photo'
        commodityData['photo'] = uploadedPath;
      } else if (_removePhoto) {
        // explicit remove -> backend expects 'photo' to be null to clear it
        commodityData['photo'] = null;
      }

      final provider = context.read<CommodityProvider>();
      await provider.createCommodity(commodityData);
      
      // Refresh the commodities list
      await provider.fetchCommodities();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unit kerja berhasil ditambahkan')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Unit Kerja'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker area
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      child: _pickedImageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _pickedImageBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.photo, size: 48, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                            if (image != null) {
                              final bytes = await image.readAsBytes();
                              setState(() {
                                _pickedImage = image;
                                _pickedImageBytes = bytes;
                                _removePhoto = false;
                              });
                            }
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Pilih Foto'),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () async {
                            final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                            if (image != null) {
                              final bytes = await image.readAsBytes();
                              setState(() {
                                _pickedImage = image;
                                _pickedImageBytes = bytes;
                                _removePhoto = false;
                              });
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Ambil Foto'),
                        ),
                        const SizedBox(width: 8),
                        if (_pickedImageBytes != null || _pickedImage != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _pickedImage = null;
                                _pickedImageBytes = null;
                                _removePhoto = true;
                              });
                            },
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            label: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Nama Unit Kerja
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Unit Kerja *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama unit kerja wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kode Unit Kerja
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Unit Kerja *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode unit kerja wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Jumlah Stok
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Stok *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok wajib diisi';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Stok harus berupa angka positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Lokasi Unit Kerja
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi Unit Kerja *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lokasi unit kerja wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Jurusan
              DropdownButtonFormField<String>(
                initialValue: _selectedJurusan,
                decoration: const InputDecoration(
                  labelText: 'Jurusan *',
                  border: OutlineInputBorder(),
                ),
                items: _jurusanOptions.map((jurusan) {
                  return DropdownMenuItem(
                    value: jurusan,
                    child: Text(jurusan),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedJurusan = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Jurusan wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Merk
              TextFormField(
                controller: _merkController,
                decoration: const InputDecoration(
                  labelText: 'Merk',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Harga Satuan
              TextFormField(
                controller: _hargaSatuanController,
                decoration: const InputDecoration(
                  labelText: 'Harga Satuan',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final harga = double.tryParse(value);
                    if (harga == null || harga < 0) {
                      return 'Harga harus berupa angka positif';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sumber
              TextFormField(
                controller: _sumberController,
                decoration: const InputDecoration(
                  labelText: 'Sumber',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Tahun
              TextFormField(
                controller: _tahunController,
                decoration: const InputDecoration(
                  labelText: 'Tahun',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final tahun = int.tryParse(value);
                    if (tahun == null || tahun < 1900 || tahun > DateTime.now().year + 1) {
                      return 'Tahun tidak valid';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
