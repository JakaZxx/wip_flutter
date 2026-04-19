import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/class_provider.dart';
import '../models/school_class.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

class AdminEditClassScreen extends StatefulWidget {
  final int? classId;

  const AdminEditClassScreen({super.key, this.classId});

  @override
  State<AdminEditClassScreen> createState() => _AdminEditClassScreenState();
}

class _AdminEditClassScreenState extends State<AdminEditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedLevel;
  String? _selectedProgramStudy;
  int? _capacity;

  List<Student> _students = [];
  bool _isLoadingStudents = false;
  bool _isSaving = false;

  List<String> _levels = [];
  List<String> _programStudies = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
    if (widget.classId != null) {
      _loadClassData();
    }
  }

  Future<void> _loadDropdownData() async {
    final classProvider = context.read<ClassProvider>();
    await classProvider.fetchClasses();

    final levels = classProvider.classes
        .map((c) => c.level)
        .where((level) => level != null)
        .toSet()
        .toList()
      ..sort();

    final programStudies = classProvider.classes
        .map((c) => c.programStudy)
        .where((program) => program != null)
        .toSet()
        .toList()
      ..sort();

    setState(() {
      _levels = levels.cast<String>();
      _programStudies = programStudies.cast<String>();
    });

    if (widget.classId == null && _levels.isNotEmpty && _programStudies.isNotEmpty) {
      _selectedLevel = _levels.first;
      _selectedProgramStudy = _programStudies.first;
    }
  }

  Future<void> _loadClassData() async {
    final classProvider = context.read<ClassProvider>();
    final schoolClass = classProvider.classes.firstWhere((c) => c.id == widget.classId);

    _nameController.text = schoolClass.name;
    _selectedLevel = schoolClass.level;
    _selectedProgramStudy = schoolClass.programStudy;
    _capacity = schoolClass.capacity;
    _descriptionController.text = schoolClass.description ?? '';

    _loadStudents();
  }

  Future<void> _loadStudents() async {
    if (widget.classId == null) return;

    setState(() => _isLoadingStudents = true);
    try {
      final students = await context.read<ClassProvider>().getClassStudents(widget.classId!);
      setState(() => _students = students);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading student roster: $e'),
            backgroundColor: AppTheme.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.classId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isEditing),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('KONFIGURASI UTAMA', 'Tentukan identitas kelas dan tingkat akademik'),
                    const SizedBox(height: 16),
                    _buildClassConfigCard(),
                    const SizedBox(height: 32),
                    if (isEditing) ...[
                      _buildStudentManagementZone(),
                      const SizedBox(height: 32),
                    ],
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isEditing) {
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
          child: const Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.school_rounded, size: 180, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          isEditing ? 'MODIFIKASI KELAS' : 'DAFTARKAN KELAS',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 2),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 2),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildClassConfigCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _buildInputField(
            controller: _nameController,
            label: 'NAMA KELAS',
            hint: 'Contoh: XII RPL 1',
            icon: Icons.badge_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Nama kelas wajib diisi' : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'TINGKAT KELAS',
                  value: _selectedLevel,
                  items: _levels.map((l) => DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 11)))).toList(),
                  onChanged: (v) => setState(() => _selectedLevel = v),
                  icon: Icons.layers_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'JURUSAN',
                  value: _selectedProgramStudy,
                  items: _programStudies.map((p) => DropdownMenuItem(
                    value: p, 
                    child: Text(p, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 1)
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedProgramStudy = v),
                  icon: Icons.auto_awesome_mosaic_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _descriptionController,
            label: 'STUDI DESKRIPSI',
            hint: 'Metadata opsional kelas...',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          decoration: AppTheme.premiumInputDecoration(hint, icon),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: value,
          items: items,
          onChanged: onChanged,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          decoration: AppTheme.premiumInputDecoration('', icon),
        ),
      ],
    );
  }

  Widget _buildStudentManagementZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('DAFTAR SISWA', '${_students.length} siswa aktif terdaftar'),
            Row(
              children: [
                _buildQuickAction(Icons.swap_horiz_rounded, AppTheme.primaryBlue, _moveStudents),
                const SizedBox(width: 8),
                _buildQuickAction(Icons.delete_sweep_outlined, AppTheme.dangerRed, _deleteAllStudents),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: _isLoadingStudents
              ? const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
              : _students.isEmpty
                  ? _buildEmptyRoster()
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _students.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) => _buildStudentItem(_students[index]),
                    ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildStudentItem(Student student) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(student.name[0].toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF1E293B))),
                Text('NIS: ${student.email}', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
          _buildQuickAction(Icons.person_remove_outlined, AppTheme.dangerRed, () => _removeStudent(student)),
        ],
      ),
    );
  }

  Widget _buildEmptyRoster() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          const Icon(Icons.people_outline_rounded, size: 48, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          Text('Tidak ada siswa ditemukan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
          Text('Kelas ini belum memiliki daftar siswa.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text('BATAL', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveClass,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('SIMPAN PERUBAHAN', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _moveStudents() async {
    final classProvider = context.read<ClassProvider>();
    final availableClasses = classProvider.classes.where((c) => c.id != widget.classId && c.programStudy == _selectedProgramStudy).toList();

    if (availableClasses.isEmpty) {
      _showError('Tidak ditemukan kelas alternatif untuk migrasi.');
      return;
    }

    if (_students.isEmpty) {
      _showError('Daftar siswa kosong. Tidak ada yang bisa dimigrasi.');
      return;
    }

    final selectedClass = await showDialog<SchoolClass>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Tujuan Migrasi', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: availableClasses.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              final schoolClass = availableClasses[index];
              return ListTile(
                title: Text(schoolClass.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text('${schoolClass.level} - ${schoolClass.programStudy}', style: GoogleFonts.poppins(fontSize: 12)),
                onTap: () => Navigator.pop(context, schoolClass),
              );
            },
          ),
        ),
      ),
    );

    if (selectedClass != null) {
      final confirm = await _showConfirmDialog('Konfirmasi Migrasi', 'Apakah Anda yakin ingin memindahkan ${_students.length} siswa ke ${selectedClass.name}?');
      if (confirm == true) {
        final studentIds = _students.map((s) => s.id).toList();
        try {
          final success = await classProvider.moveStudents(widget.classId!, selectedClass.id, studentIds);
          if (success && mounted) {
            _loadStudents();
            _showSuccess('Migrasi massal berhasil diselesaikan.');
          }
        } catch (e) {
          _showError(e.toString());
        }
      }
    }
  }

  Future<void> _deleteAllStudents() async {
    final confirm = await _showConfirmDialog('Penghapusan Massal', 'Lanjutkan menghapus seluruh daftar siswa untuk kelas ini? Tindakan ini tidak dapat dibatalkan.');
    if (confirm == true) {
      try {
        if (mounted) {
          final success = await context.read<ClassProvider>().deleteStudentsFromClass(widget.classId!);
          if (success && mounted) {
            await _loadStudents();
            _showSuccess('Seluruh daftar siswa telah dikosongkan.');
          }
        }
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _removeStudent(Student student) async {
    final confirm = await _showConfirmDialog('Hapus Registrasi', 'Hapus ${student.name} dari daftar registrasi kelas saat ini?');
    if (confirm == true) {
      try {
        if (mounted) {
          await context.read<ClassProvider>().removeStudentFromClass(widget.classId!, student.id);
          if (mounted) {
            await _loadStudents();
            _showSuccess('Registrasi siswa berhasil diperbarui.');
          }
        }
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final classData = {
        'name': _nameController.text,
        'level': _selectedLevel,
        'program_study': _selectedProgramStudy,
        'capacity': _capacity,
        'description': _descriptionController.text,
      };

      final classProvider = context.read<ClassProvider>();
      final success = widget.classId != null ? await classProvider.updateClass(widget.classId!, classData) : await classProvider.createClass(classData);

      if (success && mounted) {
        Navigator.pop(context);
        _showSuccess('Database berhasil disinkronisasi.');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('BATAL', style: GoogleFonts.outfit(color: const Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('LANJUTKAN', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showError(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: AppTheme.dangerRed, behavior: SnackBarBehavior.floating));
  }

  void _showSuccess(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: const Color(0xFF10B981), behavior: SnackBarBehavior.floating));
  }
}
