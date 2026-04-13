import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart';
import '../providers/class_provider.dart';
import '../theme/app_theme.dart';

class CreateUserForm extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const CreateUserForm({
    super.key,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedRole;
  String? _selectedJurusan;
  int? _selectedClassId;

  final List<String> _jurusanOptions = [
    'Rekayasa Perangkat Lunak',
    'Desain Komunikasi Visual',
    'Teknik Audio Video',
    'Teknik Komputer Jaringan',
    'Teknik Instalasi Tenaga Listrik',
    'Teknik Otomasi Industri',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassProvider>().fetchClasses();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(String? value) {
    setState(() {
      _selectedRole = value;
      _selectedJurusan = null;
      _selectedClassId = null;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final userData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
      'role': _selectedRole,
      if (_selectedRole == 'officers') 'jurusan': _selectedJurusan,
      if (_selectedRole == 'students') 'school_class_id': _selectedClassId,
    };

    final userProvider = context.read<UserProvider>();
    final success = await userProvider.createUser(userData);
    
    if (success && mounted) {
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User "${_nameController.text}" has been registered successfully'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('BASIC IDENTITY'),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _nameController,
                        label: 'FULL NAME',
                        hint: 'Enter user full name...',
                        icon: Icons.person_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _emailController,
                        label: 'EMAIL OR IDENTIFIER',
                        hint: 'example@aspaj.com or NIS',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email/ID wajib diisi';
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          final nisRegex = RegExp(r'^\d{5,15}$');
                          if (!emailRegex.hasMatch(v) && !nisRegex.hasMatch(v)) return 'Format tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('ACCESS CONTROL'),
                      const SizedBox(height: 16),
                      _buildRoleDropdown(),
                      const SizedBox(height: 16),
                      _buildDynamicFields(),
                      const SizedBox(height: 24),
                      _buildSectionTitle('SECURE CREDENTIALS'),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _passwordController,
                        label: 'PASSWORD',
                        hint: 'Minimum 8 characters',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: (v) => v == null || v.length < 8 ? 'Minimal 8 karakter' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _confirmPasswordController,
                        label: 'CONFIRM PASSWORD',
                        hint: 'Repeat your password',
                        icon: Icons.lock_reset_rounded,
                        isPassword: true,
                        validator: (v) => v != _passwordController.text ? 'Password tidak cocok' : null,
                      ),
                      const SizedBox(height: 40),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                'Registration Hub',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new user account with specified platform roles.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF94A3B8),
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
          decoration: AppTheme.premiumInputDecoration(hint, icon),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedRole,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1E293B),
      ),
      decoration: AppTheme.premiumInputDecoration('Select Platform Role', Icons.badge_outlined),
      items: const [
        DropdownMenuItem(value: 'admin', child: Text('ADMINISTRATOR')),
        DropdownMenuItem(value: 'officers', child: Text('OFFICER')),
        DropdownMenuItem(value: 'students', child: Text('STUDENT')),
      ],
      onChanged: _onRoleChanged,
      validator: (v) => v == null ? 'Role wajib dipilih' : null,
    );
  }

  Widget _buildDynamicFields() {
    if (_selectedRole == 'officers') {
      return DropdownButtonFormField<String>(
        initialValue: _selectedJurusan,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
        decoration: AppTheme.premiumInputDecoration('Select Department', Icons.business_rounded),
        items: _jurusanOptions.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
        onChanged: (v) => setState(() => _selectedJurusan = v),
        validator: (v) => v == null ? 'Jurusan wajib dipilih' : null,
      );
    }

    if (_selectedRole == 'students') {
      return Consumer<ClassProvider>(
        builder: (context, cp, _) {
          if (cp.isLoading) return const Center(child: CircularProgressIndicator());
          return DropdownButtonFormField<int>(
            initialValue: _selectedClassId,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
            decoration: AppTheme.premiumInputDecoration('Select assigned class', Icons.class_rounded),
            items: cp.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => _selectedClassId = v),
            validator: (v) => v == null ? 'Kelas wajib dipilih' : null,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: widget.onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'CANCEL',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Consumer<UserProvider>(
              builder: (context, up, _) {
                return ElevatedButton(
                  onPressed: up.isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: up.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          'REGISTER USER',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}


