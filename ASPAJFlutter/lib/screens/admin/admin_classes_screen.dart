import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/school_class.dart';
import 'admin_edit_class_screen.dart';

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
      appBar: AppBar(
        title: const Text('Kelola Kelas'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Consumer<ClassProvider>(
        builder: (context, classProvider, child) {
          // Update local lists when provider data changes
          _levels = classProvider.levels;
          _programStudies = classProvider.programStudies;

          if (classProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (classProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${classProvider.error}'),
                  ElevatedButton(
                    onPressed: () => classProvider.fetchClasses(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredClasses = _getFilteredClasses(classProvider.classes, isOfficer, authProvider.user?.jurusan);

          // Log for debugging
          print('AdminClassesScreen: isOfficer=$isOfficer, jurusan=${authProvider.user?.jurusan}');
          print('AdminClassesScreen: total classes=${classProvider.classes.length}, filtered=${filteredClasses.length}');

          return Column(
            children: [
              // Search and Filters
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Cari nama kelas...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        FloatingActionButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminEditClassScreen(),
                            ),
                          ),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!isOfficer) ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedLevelFilter,
                              decoration: const InputDecoration(
                                labelText: 'Filter Tingkat',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Semua Tingkat')),
                                ..._levels.map((level) {
                                  return DropdownMenuItem(
                                    value: level,
                                    child: Text('Tingkat $level'),
                                  );
                                }),
                              ],
                              onChanged: (value) => setState(() => _selectedLevelFilter = value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedProgramStudyFilter,
                              decoration: const InputDecoration(
                                labelText: 'Filter Program Studi',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Semua Program')),
                                ..._programStudies.map((program) {
                                  return DropdownMenuItem(
                                    value: program,
                                    child: Text(program),
                                  );
                                }),
                              ],
                              onChanged: (value) => setState(() => _selectedProgramStudyFilter = value),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedLevelFilter,
                              decoration: const InputDecoration(
                                labelText: 'Filter Tingkat',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Semua Tingkat')),
                                ..._levels.map((level) {
                                  return DropdownMenuItem(
                                    value: level,
                                    child: Text('Tingkat $level'),
                                  );
                                }),
                              ],
                              onChanged: (value) => setState(() => _selectedLevelFilter = value),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Classes Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: filteredClasses.length,
                  itemBuilder: (context, index) {
                    final schoolClass = filteredClasses[index];
                    return _buildClassCard(schoolClass);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  Widget _buildClassCard(SchoolClass schoolClass) {
    return Card(
      child: InkWell(
        onTap: () => _showClassDetail(schoolClass),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      schoolClass.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleClassAction(schoolClass, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'detail', child: Text('Detail')),
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Tingkat: ${schoolClass.level ?? '-'}'),
              Text('Program: ${schoolClass.programStudy ?? '-'}'),
              if (schoolClass.description != null && schoolClass.description!.isNotEmpty)
                Text(
                  'Deskripsi: ${schoolClass.description}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              Text(
                'Siswa: ${schoolClass.students?.length ?? 0}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleClassAction(SchoolClass schoolClass, String action) async {
    switch (action) {
      case 'detail':
        _showClassDetail(schoolClass);
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminEditClassScreen(classId: schoolClass.id),
          ),
        );
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus kelas ini?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
            ],
          ),
        );

        if (confirm == true) {
          final success = await context.read<ClassProvider>().deleteClass(schoolClass.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kelas berhasil dihapus')),
            );
          }
        }
        break;
    }
  }

  List<SchoolClass> _getFilteredClasses(List<SchoolClass> classes, bool isOfficer, String? officerProgramStudy) {
    // Note: Officer filtering is now handled by the backend API
    // No need for additional frontend filtering for officers

    return classes.where((schoolClass) {
      final matchesSearch = _searchController.text.isEmpty ||
          schoolClass.name.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesLevel = _selectedLevelFilter == null || schoolClass.level == _selectedLevelFilter;
      final matchesProgram = _selectedProgramStudyFilter == null || schoolClass.programStudy == _selectedProgramStudyFilter;
      return matchesSearch && matchesLevel && matchesProgram;
    }).toList();
  }

  void _showClassDetail(SchoolClass schoolClass) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(schoolClass.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tingkat: ${schoolClass.level ?? '-'}'),
            Text('Program Studi: ${schoolClass.programStudy ?? '-'}'),
            if (schoolClass.description != null && schoolClass.description!.isNotEmpty)
              Text('Deskripsi: ${schoolClass.description}'),
            Text('Jumlah Siswa: ${schoolClass.students?.length ?? 0}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
