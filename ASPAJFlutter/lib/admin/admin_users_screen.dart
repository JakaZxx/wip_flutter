import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart';
import '../providers/class_provider.dart';
import '../models/user.dart';
import '../widgets/create_user_form.dart';
import '../theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUsers();
      context.read<ClassProvider>().fetchClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(userProvider),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 24),
                      _buildFilterSection(userProvider),
                      const SizedBox(height: 28),
                      _buildSectionLabel('DAFTAR PENGGUNA TERDAFTAR'),
                      const SizedBox(height: 16),
                      if (userProvider.isLoading)
                        _buildLoadingState()
                      else if (userProvider.error != null)
                        _buildErrorState(userProvider)
                      else if (userProvider.users.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userProvider.users.length,
                          itemBuilder: (context, index) => _buildUserCardPremium(userProvider.users[index]),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateUserModal,
        backgroundColor: AppTheme.primaryBlue,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text('Tambah User', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildSliverAppBar(UserProvider userProvider) {
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
                  child: Icon(Icons.people_rounded, size: 180, color: Colors.white),
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
          'Kelola Akses',
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        Text(
          'Manajemen akun admin, petugas, dan siswa.',
          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildFilterSection(UserProvider userProvider) {
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
              hintText: 'Cari nama atau email...',
              hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 22),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
            onChanged: (v) => userProvider.fetchUsers(search: v, role: _selectedRole),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[100]),
          _buildRoleFilter(userProvider),
        ],
      ),
    );
  }

  Widget _buildRoleFilter(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          icon: const Icon(Icons.tune_rounded, color: Color(0xFF64748B), size: 20),
          hint: Text('Filter berdasarkan Role', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B))),
          items: const [
            DropdownMenuItem(value: '', child: Text('Semua Akses')),
            DropdownMenuItem(value: 'admin', child: Text('Administrator')),
            DropdownMenuItem(value: 'officers', child: Text('Petugas Lapangan')),
            DropdownMenuItem(value: 'students', child: Text('Siswa')),
          ],
          onChanged: (v) {
            setState(() => _selectedRole = v);
            userProvider.fetchUsers(search: _searchController.text, role: v);
          },
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

  Widget _buildUserCardPremium(User user) {
    final roleColor = _getRoleColorPremium(user.role);
    final statusColor = _getStatusColorPremium(user);
    final statusText = _getStatusTextPremium(user);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              user.name[0].toUpperCase(),
              style: GoogleFonts.outfit(color: roleColor, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
        title: Text(
          user.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(user.email, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildBadge(user.role.toUpperCase(), roleColor),
                const SizedBox(width: 8),
                _buildBadge(statusText, statusColor, isOutline: true),
              ],
            ),
          ],
        ),
        trailing: _buildActionMenu(user),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: isOutline ? Border.all(color: color.withValues(alpha: 0.3)) : null,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  Widget _buildActionMenu(User user) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF64748B), size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (v) => _handleUserAction(user, v),
        itemBuilder: (context) => [
          _buildPopupItem('edit', Icons.edit_note_rounded, 'Modifikasi Data', const Color(0xFF1E293B)),
          if (user.role == 'officers' && user.approvalStatus == 'pending') ...[
            _buildPopupItem('approve', Icons.verified_user_rounded, 'Setujui Akses', const Color(0xFF10B981)),
            _buildPopupItem('reject', Icons.do_not_disturb_on_rounded, 'Tolak Akses', const Color(0xFFEF4444)),
          ],
          _buildPopupItem('delete', Icons.delete_sweep_rounded, 'Hapus Akun', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  void _openCreateUserModal({User? userToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: CreateUserForm(
                userToEdit: userToEdit,
                onCancel: () => Navigator.pop(context),
                onSuccess: () {
                  Navigator.pop(context);
                  context.read<UserProvider>().fetchUsers();
                },
              ),
            ),
          ),
        ),
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
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text('Pengguna Tidak Ditemukan', style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Coba kata kunci atau filter lain.', style: GoogleFonts.poppins(color: const Color(0xFFCBD5E1), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildErrorState(UserProvider provider) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.error_outline_rounded, size: 60, color: Colors.red[200]),
          const SizedBox(height: 16),
          Text('Gagal Memuat Data', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => provider.fetchUsers(),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Muat Ulang'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColorPremium(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return const Color(0xFFEF4444);
      case 'officers': return const Color(0xFF3B82F6);
      case 'students': return const Color(0xFF10B981);
      default: return const Color(0xFF64748B);
    }
  }

  Color _getStatusColorPremium(User user) {
    if (user.role == 'officers') {
      switch (user.approvalStatus) {
        case 'approved': return const Color(0xFF10B981);
        case 'rejected': return const Color(0xFFEF4444);
        default: return const Color(0xFFF59E0B);
      }
    }
    return user.emailVerifiedAt != null ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B);
  }

  String _getStatusTextPremium(User user) {
    if (user.role == 'officers') return user.approvalStatus.toUpperCase();
    return user.emailVerifiedAt != null ? 'TERVERIFIKASI' : 'BELUM VERIFIKASI';
  }

  void _handleUserAction(User user, String action) async {
    final provider = context.read<UserProvider>();
    if (action == 'delete') {
      final confirm = await _showConfirmDialog('Hapus Pengguna', 'Anda yakin ingin menghapus akun ${user.name}?');
      if (confirm && mounted) await provider.deleteUser(user.id);
    } else if (action == 'edit') {
      _openCreateUserModal(userToEdit: user);
    } else if (action == 'approve') {
      if (mounted) await provider.approveOfficer(user.id);
    } else if (action == 'reject') {
      if (mounted) await provider.rejectOfficer(user.id);
    }
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(content, style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }
}


