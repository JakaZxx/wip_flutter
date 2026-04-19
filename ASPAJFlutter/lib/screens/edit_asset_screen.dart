// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/commodity_provider.dart';
import '../providers/auth_provider.dart';
import '../models/commodity.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class EditAssetScreen extends StatefulWidget {
  final Commodity commodity;

  const EditAssetScreen({super.key, required this.commodity});

  @override
  State<EditAssetScreen> createState() => _EditAssetScreenState();
}

class _EditAssetScreenState extends State<EditAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _stockController;
  late final TextEditingController _lokasiController;
  late final TextEditingController _merkController;
  late final TextEditingController _hargaSatuanController;
  late final TextEditingController _sumberController;
  late final TextEditingController _tahunController;
  late final TextEditingController _deskripsiController;

  String? _selectedJurusan;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _removePhoto = false;
  bool _isOfficer = false;

  final List<String> _jurusanOptions = [
    'Rekayasa Perangkat Lunak',
    'Desain Komunikasi Visual',
    'Teknik Komputer Jaringan',
    'Teknik Otomasi Industri',
    'Teknik Instalasi Tenaga Listrik',
    'Teknik Audio Video'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.commodity.name);
    _codeController = TextEditingController(text: widget.commodity.code);
    _stockController = TextEditingController(text: widget.commodity.stock.toString());
    _lokasiController = TextEditingController(text: widget.commodity.lokasi);
    _merkController = TextEditingController(text: widget.commodity.merk);
    _hargaSatuanController = TextEditingController(text: widget.commodity.hargaSatuan?.toString());
    _sumberController = TextEditingController(text: widget.commodity.sumber);
    _tahunController = TextEditingController(text: widget.commodity.tahun?.toString());
    _deskripsiController = TextEditingController(text: widget.commodity.deskripsi);
    
    // Hardened selection to prevent "Semua" or other missing item crashes
    final initialJurusan = widget.commodity.jurusan;
    if (initialJurusan != null && !_jurusanOptions.contains(initialJurusan)) {
      if (initialJurusan == 'Semua') {
        _selectedJurusan = 'Rekayasa Perangkat Lunak'; // Defaulting safely
      } else {
        _selectedJurusan = _jurusanOptions.first;
      }
    } else {
      _selectedJurusan = initialJurusan;
    }

    final user = context.read<AuthProvider>().user;
    if (user != null && user.role == 'officers') {
      _isOfficer = true;
    }
  }

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

      if (_pickedImageBytes != null && _pickedImage != null) {
        final uploadedPath = await ApiService().uploadBytes(_pickedImageBytes!, _pickedImage!.name, 'file');
        commodityData['photo'] = uploadedPath;
      } else if (_removePhoto) {
        commodityData['photo'] = null;
      }
      
      final provider = context.read<CommodityProvider>();
      await provider.updateCommodity(widget.commodity.id, commodityData);
      await provider.fetchCommodities();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} berhasil diperbarui'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui: $e'),
            backgroundColor: AppTheme.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Updated to match HelpSupportScreen
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('DOKUMENTASI VISUAL', 'Pratinjau Foto Aset Terkini'),
                    const SizedBox(height: 16),
                    _buildImagePickerSection(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('INFORMASI IDENTITAS', 'Katalog Dasar & Kodifikasi'),
                    const SizedBox(height: 20),
                    _buildPremiumField(_nameController, 'NAMA ASET / UNIT KERJA', 'Masukkan nama aset...', Icons.inventory_2_outlined),
                    const SizedBox(height: 16),
                    _buildPremiumField(_codeController, 'KODE INVENTARIS', 'Contoh: ELK-001', Icons.qr_code_2_rounded),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildPremiumField(_stockController, 'JUMLAH STOK', '0', Icons.format_list_numbered_rounded, keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _isOfficer 
                              ? _buildLockedJurusanField(_selectedJurusan ?? 'Unknown')
                              : _buildModernDropdown(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('SPESIFIKASI & PENEMPATAN', 'Detail Teknis & Lokasi Aset'),
                    const SizedBox(height: 20),
                    _buildPremiumField(_lokasiController, 'LOKASI PENEMPATAN', 'Contoh: Lab RPL 1', Icons.location_on_outlined),
                    const SizedBox(height: 16),
                    _buildPremiumField(_merkController, 'MERK / BRAND', 'Masukkan merk barang...', Icons.branding_watermark_outlined),
                    const SizedBox(height: 16),
                    _buildPremiumField(_hargaSatuanController, 'HARGA SATUAN (RP)', '0', Icons.payments_outlined, keyboardType: TextInputType.number),
                    const SizedBox(height: 32),
                    _buildSectionHeader('RIWAYAT PEROLEHAN', 'Administrasi & Keterangan Tambahan'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildPremiumField(_sumberController, 'SUMBER DANA', 'APBD / BOS / HIBAH', Icons.source_outlined)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPremiumField(_tahunController, 'TAHUN PEROLEHAN', '2024', Icons.calendar_today_outlined, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPremiumField(_deskripsiController, 'DESKRIPSI KONDISI', 'Opsional: Catatan mengenai kondisi aset...', Icons.description_outlined, maxLines: 3),
                    const SizedBox(height: 48),
                    _buildSubmitButton(),
                    const SizedBox(height: 100),
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
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text('MODIFIKASI ASET', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 2)),
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              Positioned(
                right: -20, bottom: -20,
                child: Opacity(opacity: 0.1, child: FaIcon(FontAwesomeIcons.penToSquare, size: 140, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF475569), letterSpacing: 2)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildImagePickerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: _pickedImageBytes != null
                  ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                  : (widget.commodity.fixedPhotoUrl != null && !_removePhoto
                      ? Image.network(widget.commodity.fixedPhotoUrl!, fit: BoxFit.cover)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.image, size: 30, color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              Text('TIDAK ADA FOTO', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                            ],
                          ),
                        )),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSmallActionBtn(Icons.photo_library_outlined, 'GALERI', () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  setState(() { _pickedImage = image; _pickedImageBytes = bytes; _removePhoto = false; });
                }
              })),
              const SizedBox(width: 8),
              Expanded(child: _buildSmallActionBtn(Icons.camera_alt_outlined, 'KAMERA', () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  setState(() { _pickedImage = image; _pickedImageBytes = bytes; _removePhoto = false; });
                }
              })),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSmallActionBtn(Icons.delete_outline_rounded, 'HAPUS', () {
                  setState(() { _pickedImage = null; _pickedImageBytes = null; _removePhoto = true; });
                }, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionBtn(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final themeColor = color ?? AppTheme.primaryBlue;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: themeColor),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: themeColor, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumField(TextEditingController controller, String label, String hint, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            decoration: AppTheme.premiumInputDecoration(hint, icon).copyWith(
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            validator: (v) => (v == null || v.trim().isEmpty) && label.contains('*') ? 'Wajib diisi' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLockedJurusanField(String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PROGRAM KEAHLIAN / JURUSAN', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 56, // Match dropdown height
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PROGRAM KEAHLIAN / JURUSAN', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            key: ValueKey('jurusan_$_selectedJurusan'),
            initialValue: _selectedJurusan,
            icon: const Icon(Icons.expand_more_rounded, size: 18, color: Color(0xFF94A3B8)),
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              prefixIcon: Icon(Icons.business_rounded, color: AppTheme.primaryBlue, size: 20),
            ),
            items: _jurusanOptions.map((j) => DropdownMenuItem(value: j, child: Text(j, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (v) => setState(() => _selectedJurusan = v),
            validator: (v) => v == null ? 'Pilih' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppTheme.primaryGradient,
        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Text('SINKRONISASI DATA ASET', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white, letterSpacing: 1.5)),
      ),
    );
  }
}
