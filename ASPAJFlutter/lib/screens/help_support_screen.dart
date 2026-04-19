import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/bug_report_service.dart';
import '../theme/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedDeviceType;
  String? _selectedBugType;
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  bool _isSubmitting = false;

  final List<String> _deviceTypes = ['mobile', 'desktop'];
  final List<String> _bugTypes = ['tampilan', 'sistem'];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final bugReportService = BugReportService();
      final Map<String, dynamic> bugData = {
        'device_type': _selectedDeviceType,
        'bug_type': _selectedBugType,
        'bug_description': _descriptionController.text,
      };

      if (_selectedImage != null) {
        if (kIsWeb) {
          bugData['bug_image_path'] = await _selectedImage!.readAsBytes();
          bugData['image_filename'] = _selectedImage!.name;
        } else {
          bugData['bug_image_path'] = _selectedImage!.path;
        }
      }

      await bugReportService.submitBugReport(bugData);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 60),
            content: Text('Laporan berhasil dikirim! Tim audit akan segera memproses informasi ini.', 
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('MENGERTI', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sinkronisasi gagal: $e'),
          backgroundColor: AppTheme.dangerRed,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
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
                    _buildSectionHeader('IDENTIFIKASI ANOMALI', 'Detail Perangkat & Jenis Masalah'),
                    const SizedBox(height: 20),
                    _buildDeviceAndBugTypeFields(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('BUKTI VISUAL', 'Lampirkan Screenshot Jika Ada'),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('DESKRIPSI MASALAH', 'Jelaskan Kronologi Secara Detail'),
                    const SizedBox(height: 16),
                    _buildDescriptionField(),
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
        title: Text('LAPORAN MASALAH', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Opacity(
            opacity: 0.1,
            child: Center(child: FaIcon(FontAwesomeIcons.bugSlash, size: 100, color: Colors.white)),
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
        Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF475569), letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildDeviceAndBugTypeFields() {
    return Row(
      children: [
        Expanded(
          child: _buildModernDropdown(
            value: _selectedDeviceType,
            hint: 'DEVICE TYPE',
            items: _deviceTypes,
            icon: FontAwesomeIcons.laptop,
            onChanged: (v) => setState(() => _selectedDeviceType = v),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildModernDropdown(
            value: _selectedBugType,
            hint: 'BUG TYPE',
            items: _bugTypes,
            icon: FontAwesomeIcons.bug,
            onChanged: (v) => setState(() => _selectedBugType = v),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown({String? value, required String hint, required List<String> items, required dynamic icon, required Function(String?) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          key: ValueKey('dropdown_$value'),
          initialValue: value,
          icon: const Icon(Icons.expand_more_rounded, size: 18, color: Color(0xFF94A3B8)),
          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          hint: Row(
            children: [
              FaIcon(icon, size: 14, color: AppTheme.primaryBlue.withValues(alpha: 0.5)),
              const SizedBox(width: 10),
              Text(hint, style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          items: items.map((t) => DropdownMenuItem(
            value: t, 
            child: Text(t.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5))
          )).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          validator: (v) => v == null ? 'Required' : null,
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2, style: BorderStyle.solid),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: kIsWeb
                    ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.05), shape: BoxShape.circle),
                    child: const FaIcon(FontAwesomeIcons.image, color: AppTheme.primaryBlue, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text('KETUK UNTUK UNGGAH BUKTI', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
                ],
              ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 6,
        style: GoogleFonts.poppins(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Jelaskan secara mendalam anomali yang ditemukan...',
          hintStyle: GoogleFonts.poppins(color: const Color(0xFFCBD5E1), fontSize: 13),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
        validator: (v) => v == null || v.isEmpty ? 'Keterangan wajib diisi' : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('KIRIM LAPORAN SISTEM', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
      ),
    );
  }
}
