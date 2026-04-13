// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/commodity_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePickerSection(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('INFORMASI DASAR'),
                    const SizedBox(height: 16),
                    _buildPremiumTextField(_nameController, 'Nama Aset / Unit Kerja', Icons.inventory_2_outlined),
                    const SizedBox(height: 16),
                    _buildPremiumTextField(_codeController, 'Kode Aset', Icons.qr_code_2_rounded),
                    const SizedBox(height: 16),
                    _buildPremiumTextField(_stockController, 'Jumlah Stok', Icons.format_list_numbered_rounded, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildPremiumDropdown(_selectedJurusan, 'Jurusan / Departemen', _jurusanOptions, (v) => setState(() => _selectedJurusan = v)),
                    const SizedBox(height: 32),
                    _buildSectionHeader('DETAIL & LOKASI'),
                    const SizedBox(height: 16),
                    _buildPremiumTextField(_lokasiController, 'Lokasi Penempatan', Icons.location_on_outlined),
                    const SizedBox(height: 16),
                    _buildPremiumTextField(_merkController, 'Merk / Brand', Icons.branding_watermark_outlined),
                    const SizedBox(height: 16),
                    _buildPremiumTextField(_hargaSatuanController, 'Harga Satuan (Rp)', Icons.payments_outlined, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildPremiumTextField(_sumberController, 'Sumber Perolehan', Icons.source_outlined),
                    const SizedBox(height: 16),
                    _buildPremiumTextField(_tahunController, 'Tahun Perolehan', Icons.calendar_today_outlined, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    _buildPremiumTextField(_deskripsiController, 'Deskripsi Tambahan', Icons.description_outlined, maxLines: 3),
                    const SizedBox(height: 48),
                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'Tambah Aset Baru',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.2),
    );
  }

  Widget _buildImagePickerSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
              border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: _pickedImageBytes != null
                  ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                  : Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[300]),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallIconButton(Icons.photo_library_outlined, 'Galeri', () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (image != null) _setPickedImage(image);
              }),
              const SizedBox(width: 12),
              _buildSmallIconButton(Icons.camera_alt_outlined, 'Kamera', () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (image != null) _setPickedImage(image);
              }),
              if (_pickedImageBytes != null) ...[
                const SizedBox(width: 12),
                _buildSmallIconButton(Icons.delete_outline_rounded, 'Hapus', () {
                  setState(() { _pickedImage = null; _pickedImageBytes = null; _removePhoto = true; });
                }, color: Colors.red),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _setPickedImage(XFile image) async {
    final bytes = await image.readAsBytes();
    setState(() {
      _pickedImage = image;
      _pickedImageBytes = bytes;
      _removePhoto = false;
    });
  }

  Widget _buildSmallIconButton(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color ?? AppTheme.primaryBlue),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color ?? AppTheme.primaryBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Field ini wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildPremiumDropdown(String? value, String label, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Pilih Opsi', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: GoogleFonts.poppins(fontSize: 14)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [AppTheme.primaryBlue, Color(0xFF2563EB)]),
        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('SIMPAN ASET', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
      ),
    );
  }
}

