import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../models/school_class.dart';
import '../../models/student.dart';

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

    // Set default values for new class
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
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingStudents = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.classId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kelas' : 'Tambah Kelas'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Kelas' : 'Tambah Kelas Baru',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Kelas',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama kelas wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: const InputDecoration(
                          labelText: 'Tingkat',
                          border: OutlineInputBorder(),
                        ),
                        items: _levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text('Tingkat $level'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedLevel = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tingkat wajib dipilih';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedProgramStudy,
                        decoration: const InputDecoration(
                          labelText: 'Program Studi',
                          border: OutlineInputBorder(),
                        ),
                        items: _programStudies.map((program) {
                          return DropdownMenuItem(
                            value: program,
                            child: Text(program),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedProgramStudy = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Program studi wajib dipilih';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Students Section (only for editing)
              if (isEditing) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Siswa (${_students.length})',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _moveStudents,
                                  icon: const Icon(Icons.swap_horiz),
                                  label: const Text('Pindah Siswa'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _deleteAllStudents,
                                  icon: const Icon(Icons.delete_sweep),
                                  label: const Text('Hapus Semua'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isLoadingStudents)
                          const Center(child: CircularProgressIndicator())
                        else if (_students.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Tidak ada siswa di kelas ini'),
                            ),
                          )
                        else
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              itemCount: _students.length,
                              itemBuilder: (context, index) {
                                final student = _students[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(student.name[0].toUpperCase()),
                                  ),
                                  title: Text(student.name),
                                  subtitle: Text('ID: ${student.id}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeStudent(student),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveClass,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _moveStudents() async {
    final classProvider = context.read<ClassProvider>();
    final availableClasses = classProvider.classes.where((c) => c.id != widget.classId && c.programStudy == _selectedProgramStudy).toList();

    if (availableClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada kelas lain untuk dipindahkan')),
      );
      return;
    }

    if (_students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada siswa di kelas ini untuk dipindahkan')),
      );
      return;
    }

    final selectedClass = await showDialog<SchoolClass>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Kelas Tujuan'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableClasses.length,
            itemBuilder: (context, index) {
              final schoolClass = availableClasses[index];
              return ListTile(
                title: Text(schoolClass.name),
                subtitle: Text('${schoolClass.level ?? ''} - ${schoolClass.programStudy ?? ''}'),
                onTap: () => Navigator.pop(context, schoolClass),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (selectedClass != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text('Yakin ingin memindahkan semua ${_students.length} siswa ke kelas ${selectedClass.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Pindah')),
          ],
        ),
      );

      if (confirm == true) {
        final studentIds = _students.map((s) => s.id).toList();
        try {
          final success = await classProvider.moveStudents(
            widget.classId!,
            selectedClass.id,
            studentIds,
          );
          if (success && mounted) {
            _loadStudents();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Semua siswa berhasil dipindahkan')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      }
    }
  }

  Future<void> _deleteAllStudents() async {
    print('AdminEditClassScreen._deleteAllStudents: Starting delete all students from class ${widget.classId}');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus semua siswa dari kelas ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    print('AdminEditClassScreen._deleteAllStudents: User confirmation: $confirm');

    if (confirm == true) {
      print('AdminEditClassScreen._deleteAllStudents: Proceeding with delete all');
      try {
        final success = await context.read<ClassProvider>().deleteStudentsFromClass(widget.classId!);
        print('AdminEditClassScreen._deleteAllStudents: Delete all result: $success');
        if (success && mounted) {
          print('AdminEditClassScreen._deleteAllStudents: Reloading students');
          await _loadStudents();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Semua siswa berhasil dihapus')),
          );
        }
      } catch (e) {
        print('AdminEditClassScreen._deleteAllStudents: Error occurred: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error menghapus semua siswa: $e')),
          );
        }
      }
    } else {
      print('AdminEditClassScreen._deleteAllStudents: User cancelled the operation');
    }
  }

  Future<void> _removeStudent(Student student) async {
    print('AdminEditClassScreen._removeStudent: Starting removal of student ${student.name} (ID: ${student.id}) from class ${widget.classId}');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Yakin ingin menghapus siswa ${student.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    print('AdminEditClassScreen._removeStudent: User confirmation: $confirm');

    if (confirm == true) {
      print('AdminEditClassScreen._removeStudent: Proceeding with removal');
      try {
        await context.read<ClassProvider>().removeStudentFromClass(widget.classId!, student.id);
        print('AdminEditClassScreen._removeStudent: Removal successful, reloading students');
        if (mounted) {
          await _loadStudents();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Siswa ${student.name} berhasil dihapus')),
          );
        }
      } catch (e) {
        print('AdminEditClassScreen._removeStudent: Error occurred: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error menghapus siswa: $e')),
          );
        }
      }
    } else {
      print('AdminEditClassScreen._removeStudent: User cancelled the operation');
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
      bool success;

      if (widget.classId != null) {
        success = await classProvider.updateClass(widget.classId!, classData);
      } else {
        success = await classProvider.createClass(classData);
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kelas berhasil ${widget.classId != null ? 'diupdate' : 'ditambahkan'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
