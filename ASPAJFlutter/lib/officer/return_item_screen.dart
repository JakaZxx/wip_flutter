import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/borrowing_item.dart';
import '../models/commodity.dart';
import '../providers/borrowing_provider.dart';
import '../theme/app_theme.dart';

class ReturnItemScreen extends StatefulWidget {
  final BorrowingItem item;

  const ReturnItemScreen({super.key, required this.item});

  @override
  State<ReturnItemScreen> createState() => _ReturnItemScreenState();
}

class _ReturnItemScreenState extends State<ReturnItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conditionController = TextEditingController();
  XFile? _image;
  String _selectedCondition = 'good';
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickAndCropImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (pickedFile == null) return;

      CroppedFile? croppedFile;
      if (mounted) {
        final webSettings = WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(width: 400, height: 400),
        );

        try {
          croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Validasi Foto Barang',
                toolbarColor: AppTheme.primaryBlue,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false,
              ),
              IOSUiSettings(title: 'Validasi Foto Barang'),
              webSettings,
            ],
          );
        } catch (e) {
          debugPrint('Cropping failed: $e');
        }
      }

      if (!mounted) return;
      setState(() {
        _image = XFile(croppedFile?.path ?? pickedFile.path, name: pickedFile.name);
      });
    } catch (e) {
      if (mounted) _showError('Gagal mengambil gambar: $e');
    }
  }

  void _showError(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: AppTheme.dangerRed, behavior: SnackBarBehavior.floating));
  }

  Future<void> _submitReturn() async {
    if (_image == null) {
      _showError('Foto validasi barang wajib dilampirkan.');
      return;
    }

    setState(() => _isLoading = true);

    final returnData = {
      'condition': '$_selectedCondition: ${_conditionController.text}'.trim(),
      'return_photo': _image,
    };

    try {
      if (widget.item.borrowingId == null || widget.item.id == null) {
        throw Exception('Metadata transaksi tidak lengkap.');
      }

      await context.read<BorrowingProvider>().returnBorrowingItem(
            widget.item.borrowingId!,
            widget.item.id!,
            returnData,
          );

      if (mounted) {
        _showSuccess('Pengembalian berhasil disinkronisasi.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _showError('Sinkronisasi gagal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final commodity = widget.item.commodity;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildAssetIdentityCard(commodity),
                    const SizedBox(height: 32),
                    _buildSectionHeader('PENILAIAN KONDISI', 'Laporan Status'),
                    const SizedBox(height: 16),
                    _buildConditionIntelligence(),
                    const SizedBox(height: 24),
                    _buildDetailedNotes(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('VALIDASI VISUAL', 'Bukti Pengembalian'),
                    const SizedBox(height: 16),
                    _buildPhotoVault(),
                    const SizedBox(height: 48),
                    _buildSubmitAction(),
                    const SizedBox(height: 60),
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
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              const Positioned(
                right: -30,
                bottom: -30,
                child: Opacity(opacity: 0.1, child: FaIcon(FontAwesomeIcons.boxOpen, size: 160, color: Colors.white)),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text('PENGEMBALIAN BARANG', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22, letterSpacing: 2)),
                    Text('Validasi Pengembalian Resmi', style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssetIdentityCard(Commodity? c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
            child: c?.fixedPhotoUrl != null
                ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(c!.fixedPhotoUrl!, fit: BoxFit.cover))
                : const Icon(Icons.inventory_2_rounded, color: Color(0xFFCBD5E1), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c?.name ?? 'Aset Tidak Diketahui', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: const Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text('TRANSAKSI #${widget.item.borrowingId}', style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('${widget.item.quantity} UNIT DIPINJAM', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 9, color: AppTheme.primaryBlue)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: const Color(0xFF475569))),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }

  Widget _buildConditionIntelligence() {
    return Row(
      children: [
        _buildConditionChip('good', Icons.check_circle_rounded, const Color(0xFF10B981)),
        const SizedBox(width: 12),
        _buildConditionChip('fair', Icons.info_rounded, Colors.orange),
        const SizedBox(width: 12),
        _buildConditionChip('poor', Icons.warning_rounded, AppTheme.dangerRed),
      ],
    );
  }

  Widget _buildConditionChip(String val, IconData icon, Color color) {
    String label = val.toUpperCase();
    if (val == 'good') label = 'BAIK';
    if (val == 'fair') label = 'RUSAK RINGAN';
    if (val == 'poor') label = 'RUSAK BERAT';

    final bool isSelected = _selectedCondition == val;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCondition = val),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0)),
            boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : color),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 10, color: isSelected ? Colors.white : const Color(0xFF475569))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedNotes() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _conditionController,
        maxLines: 4,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Detail tambahan kondisi barang (opsional)...',
          hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildPhotoVault() {
    return GestureDetector(
      onTap: _pickAndCropImage,
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: _image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    kIsWeb ? Image.network(_image!.path, fit: BoxFit.cover) : Image.file(File(_image!.path), fit: BoxFit.cover),
                    Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent]))),
                    Center(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle), child: const Icon(Icons.refresh_rounded, color: Colors.white))),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.05), shape: BoxShape.circle), child: const Icon(Icons.add_a_photo_rounded, size: 32, color: AppTheme.primaryBlue)),
                    const SizedBox(height: 16),
                    Text('AMBIL FOTO BARANG', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: AppTheme.primaryBlue, fontSize: 12, letterSpacing: 1.5)),
                    Text('Diperlukan bukti visual pengembalian', style: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 10)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSubmitAction() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitReturn,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 12,
          shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user_rounded, size: 20),
                  const SizedBox(width: 12),
                  Text('PROSES VALIDASI', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
                ],
              ),
      ),
    );
  }
}
