import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/class_provider.dart';
import '../providers/auth_provider.dart';
import '../models/school_class.dart';
import 'admin_edit_class_screen.dart';
import '../theme/app_theme.dart';

class AdminClassesScreen extends StatefulWidget {
  const AdminClassesScreen({super.key});

  @override
  State<AdminClassesScreen> createState() => _AdminClassesScreenState();
}

class _AdminClassesScreenState extends State<AdminClassesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLevelFilter;
  String? _selectedProgramStudyFilter;
  List<String> _levels = [];
  List<String> _programStudies = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassProvider>().fetchClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isOfficer = authProvider.user?.isOfficer ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<ClassProvider>(
        builder: (context, classProvider, child) {
          _levels = classProvider.levels;
          _programStudies = classProvider.programStudies;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 24),
                      _buildFilterSection(isOfficer),
                      const SizedBox(height: 32),
                      _buildSectionLabel('DAFTAR KELAS & JURUSAN'),
                      const SizedBox(height: 16),
                      if (classProvider.isLoading)
                        _buildLoadingState()
                      else if (classProvider.error != null)
                        _buildErrorState(classProvider)
                      else if (_getFilteredClasses(classProvider.classes, isOfficer, authProvider.user?.jurusan).isEmpty)
                        _buildEmptyState()
                      else
                        _buildClassesGrid(classProvider, isOfficer, authProvider.user?.jurusan),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isOfficer ? null : FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEditClassScreen())),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        label: Text('Tambah Kelas', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
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
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.school_rounded, size: 160, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: Text(
          'PUSAT AKADEMIK',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Struktur Kelas',
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        Text(
          'Manajemen data kelas dan program keahlian.',
          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildFilterSection(bool isOfficer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Cari nama kelas...',
              hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 22),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(_selectedLevelFilter, 'Tingkat', _levels.map((l) => 'Lvl $l').toList(), _levels, (v) => setState(() => _selectedLevelFilter = v)),
                ),
                if (!isOfficer) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterDropdown(_selectedProgramStudyFilter, 'Program', _programStudies, _programStudies, (v) => setState(() => _selectedProgramStudyFilter = v)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String? value, String label, List<String> displayItems, List<String> values, Function(String?) onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF64748B), size: 20),
        hint: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
        items: [
          const DropdownMenuItem(value: null, child: Text('Semua')),
          ...List.generate(values.length, (i) => DropdownMenuItem(value: values[i], child: Text(displayItems[i], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.5),
    );
  }

  Widget _buildClassesGrid(ClassProvider provider, bool isOfficer, String? jurusan) {
    final filtered = _getFilteredClasses(provider.classes, isOfficer, jurusan);
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) => _buildClassCardPremium(filtered[i]),
    );
  }

  Widget _buildClassCardPremium(SchoolClass schoolClass) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showClassDetailPremium(schoolClass),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: Text('Lvl ${schoolClass.level ?? '-'}', style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
                const SizedBox(height: 12),
                Text(
                  schoolClass.name,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  schoolClass.programStudy ?? '-',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.group_rounded, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text('${schoolClass.students?.length ?? 0}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                      ],
                    ),
                    _buildMoreActionMenu(schoolClass),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreActionMenu(SchoolClass schoolClass) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings_rounded, size: 16, color: Color(0xFFCBD5E1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (v) => _handleClassAction(schoolClass, v),
      itemBuilder: (context) => [
        _buildPopupItem('detail', Icons.visibility_rounded, 'Lihat Detail', const Color(0xFF1E293B)),
        _buildPopupItem('edit', Icons.edit_note_rounded, 'Ubah Data', const Color(0xFF1E293B)),
        _buildPopupItem('delete', Icons.delete_forever_rounded, 'Hapus Kelas', const Color(0xFFEF4444)),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  void _showClassDetailPremium(SchoolClass schoolClass) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(schoolClass.name, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
            const SizedBox(height: 24),
            _buildDetailCard(Icons.layers_rounded, 'Tingkat Pendidikan', 'Level ${schoolClass.level ?? '-'}'),
            _buildDetailCard(Icons.school_rounded, 'Program Keahlian', schoolClass.programStudy ?? '-'),
            _buildDetailCard(Icons.group_rounded, 'Total Siswa Terdaftar', '${schoolClass.students?.length ?? 0} Orang'),
            _buildDetailCard(Icons.info_outline_rounded, 'Deskripsi', schoolClass.description ?? 'Tidak ada deskripsi tambahan untuk kelas ini.'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('TUTUP', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)]),
            child: Icon(icon, size: 20, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8))),
                Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: AppTheme.primaryBlue)));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Icon(Icons.door_sliding_rounded, size: 100, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text('Kelas Belum Terdaftar', style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Mulai dengan menambahkan data kelas baru.', style: GoogleFonts.poppins(color: const Color(0xFFCBD5E1), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildErrorState(ClassProvider provider) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.report_gmailerrorred_rounded, size: 60, color: Colors.red[200]),
          const SizedBox(height: 16),
          Text('Gangguan Koneksi Data', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => provider.fetchClasses(),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _handleClassAction(SchoolClass schoolClass, String action) async {
    switch (action) {
      case 'detail':
        _showClassDetailPremium(schoolClass);
        break;
      case 'edit':
        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminEditClassScreen(classId: schoolClass.id)));
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Hapus Kelas', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Text('Anda yakin ingin menghapus data kelas ${schoolClass.name}? Seluruh data siswa terkait akan terpengaruh.', style: GoogleFonts.poppins(fontSize: 14)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirm == true && mounted) {
          final success = await context.read<ClassProvider>().deleteClass(schoolClass.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data kelas berhasil dihapus'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
          }
        }
        break;
    }
  }

  List<SchoolClass> _getFilteredClasses(List<SchoolClass> classes, bool isOfficer, String? officerProgramStudy) {
    return classes.where((schoolClass) {
      final matchesSearch = _searchController.text.isEmpty || schoolClass.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesLevel = _selectedLevelFilter == null || schoolClass.level == _selectedLevelFilter;
      
      bool matchesProgram = true;
      if (isOfficer) {
        if (officerProgramStudy != null && officerProgramStudy.isNotEmpty) {
          final pStudy = schoolClass.programStudy?.toLowerCase() ?? '';
          final oStudy = officerProgramStudy.toLowerCase();
          matchesProgram = pStudy.contains(oStudy) || oStudy.contains(pStudy);
          if (!matchesProgram) {
            final keywords = oStudy.split(' ').where((w) => w.length > 2);
            for (final kw in keywords) {
              if (pStudy.contains(kw)) matchesProgram = true;
            }
          }
        }
      } else {
        matchesProgram = _selectedProgramStudyFilter == null || schoolClass.programStudy == _selectedProgramStudyFilter;
      }
      
      return matchesSearch && matchesLevel && matchesProgram;
    }).toList();
  }
}


