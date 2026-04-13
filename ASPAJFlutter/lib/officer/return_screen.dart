import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../providers/borrowing_provider.dart';
import '../models/borrowing.dart';
import '../theme/app_theme.dart';

class ReturnScreen extends StatefulWidget {
  final Borrowing borrowing;

  const ReturnScreen({super.key, required this.borrowing});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  File? _returnPhoto;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('INFORMASI PEMINJAMAN'),
                    const SizedBox(height: 16),
                    _buildBorrowingDetailCard(),
                    const SizedBox(height: 32),
                    _buildSectionLabel('SPESIFIKASI PENGEMBALIAN'),
                    const SizedBox(height: 16),
                    _buildReturnForm(),
                    const SizedBox(height: 32),
                    _buildSectionLabel('BUKTI PENGEMBALIAN'),
                    const SizedBox(height: 16),
                    _buildPhotoSection(),
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
      expandedHeight: 120,
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
          child: const Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.assignment_return_rounded, size: 180, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: Text(
          'PENGEMBALIAN ASET',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.5),
    );
  }

  Widget _buildBorrowingDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REQ-${widget.borrowing.id.toString().padLeft(5, '0')}',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'SIAP DIKEMBALIKAN',
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(Icons.calendar_today_rounded, 'Tanggal Pinjam', widget.borrowing.borrowDate.toString().split(' ')[0]),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.person_outline_rounded, 'Peminjam', widget.borrowing.userName ?? 'Tidak Diketahui'),
          if (widget.borrowing.tujuan != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(Icons.notes_rounded, 'Tujuan', widget.borrowing.tujuan!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Text('$label: ', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B))),
        Expanded(
          child: Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
        ),
      ],
    );
  }

  Widget _buildReturnForm() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KONDISI BARANG',
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.verified_user_rounded, color: AppTheme.primaryBlue, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              items: ['good', 'fair', 'poor', 'damaged'].map((val) {
                return DropdownMenuItem(
                  value: val,
                  child: Text(val.toUpperCase(), style: GoogleFonts.poppins(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _conditionController.text = value ?? ''),
              validator: (v) => v == null || v.isEmpty ? 'Kondisi wajib dipilih' : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildInputField(
          controller: _notesController,
          label: 'CATATAN PETUGAS',
          hint: 'Tambahkan catatan jika diperlukan...',
          icon: Icons.edit_note_rounded,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: const Color(0xFFCBD5E1), fontSize: 13),
            prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: _returnPhoto != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(_returnPhoto!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    onPressed: () => setState(() => _returnPhoto = null),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppTheme.dangerRed, shape: BoxShape.circle),
                      child: const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                  child: const Icon(Icons.camera_enhance_rounded, size: 40, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 16),
                Text('Unggah Kondisi Aset', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Ambil foto bukti pengembalian.', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCaptureButton(Icons.camera_alt_rounded, 'KAMERA', () => _pickImage(ImageSource.camera)),
                    const SizedBox(width: 16),
                    _buildCaptureButton(Icons.photo_library_rounded, 'GALERI', () => _pickImage(ImageSource.gallery)),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildCaptureButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), AppTheme.primaryBlue]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitReturn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                'VALIDASI PENGEMBALIAN',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2.0),
              ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _returnPhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReturn() async {
    if (!_formKey.currentState!.validate()) return;

    if (_returnPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sertakan bukti foto pengembalian'),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final borrowingProvider = context.read<BorrowingProvider>();

      final returnData = {
        'return_condition': _conditionController.text,
        'return_notes': _notesController.text,
        'return_photo': _returnPhoto,
        'return_date': DateTime.now().toIso8601String(),
      };

      await borrowingProvider.returnBorrowing(widget.borrowing.id, returnData);

      if (mounted) {
        _showSuccessAnimation();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
              child: const Icon(Icons.verified_rounded, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('Validasi Berhasil!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Pengembalian aset telah berhasil divalidasi dan dicatat.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('KEMBALI KE STATUS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _conditionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}


