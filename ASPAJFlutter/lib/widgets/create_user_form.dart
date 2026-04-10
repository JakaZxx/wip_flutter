import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/class_provider.dart';

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
    // Fetch classes when form is initialized
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

    final success = await context.read<UserProvider>().createUser(userData);
    if (success && mounted) {
      widget.onSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil ditambahkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah User',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'officers', child: Text('Officers')),
                  DropdownMenuItem(value: 'students', child: Text('Students')),
                ],
                onChanged: _onRoleChanged,
                validator: (value) {
                  if (value == null) {
                    return 'Role wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Jurusan Field (for officers)
              if (_selectedRole == 'officers')
                DropdownButtonFormField<String>(
                  initialValue: _selectedJurusan,
                  decoration: const InputDecoration(
                    labelText: 'Jurusan',
                    border: OutlineInputBorder(),
                  ),
                  items: _jurusanOptions.map((jurusan) {
                    return DropdownMenuItem(
                      value: jurusan,
                      child: Text(jurusan),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedJurusan = value),
                  validator: (value) {
                    if (_selectedRole == 'officers' && value == null) {
                      return 'Jurusan wajib dipilih untuk officers';
                    }
                    return null;
                  },
                ),

              // Class Field (for students)
              if (_selectedRole == 'students')
                Consumer<ClassProvider>(
                  builder: (context, classProvider, child) {
                    if (classProvider.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      initialValue: _selectedClassId,
                      decoration: const InputDecoration(
                        labelText: 'Kelas',
                        border: OutlineInputBorder(),
                      ),
                      items: classProvider.classes.map((schoolClass) {
                        return DropdownMenuItem(
                          value: schoolClass.id,
                          child: Text(schoolClass.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedClassId = value),
                      validator: (value) {
                        if (_selectedRole == 'students' && value == null) {
                          return 'Kelas wajib dipilih untuk students';
                        }
                        return null;
                      },
                    );
                  },
                ),

              if (_selectedRole == 'officers' || _selectedRole == 'students')
                const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Password minimal 8 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      return ElevatedButton(
                        onPressed: userProvider.isLoading ? null : _submitForm,
                        child: userProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Simpan'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
