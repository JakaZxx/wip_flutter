import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/class_provider.dart';
import '../models/user.dart';
import '../widgets/create_user_form.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  bool _showCreateForm = false;

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
      appBar: AppBar(
        title: const Text('Kelola User'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${userProvider.error}'),
                  ElevatedButton(
                    onPressed: () => userProvider.fetchUsers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search and Filter
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Cari nama / email...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          userProvider.fetchUsers(search: value, role: _selectedRole);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedRole,
                      hint: const Text('Semua Role'),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('Semua Role')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'officers', child: Text('Officers')),
                        DropdownMenuItem(value: 'students', child: Text('Students')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedRole = value);
                        userProvider.fetchUsers(search: _searchController.text, role: value);
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _showCreateForm = true),
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah User'),
                    ),
                  ],
                ),
              ),

              // Create Form
              if (_showCreateForm) _buildCreateForm(),

              // Users List
              Expanded(
                child: ListView.builder(
                  itemCount: userProvider.users.length,
                  itemBuilder: (context, index) {
                    final user = userProvider.users[index];
                    return _buildUserCard(user);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreateForm() {
    return CreateUserForm(
      onCancel: () => setState(() => _showCreateForm = false),
      onSuccess: () {
        setState(() => _showCreateForm = false);
        context.read<UserProvider>().fetchUsers();
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(user.role),
              backgroundColor: _getRoleColor(user.role),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(_getStatusText(user)),
              backgroundColor: _getStatusColor(user),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(user, value),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (user.role == 'officers' && user.approvalStatus == 'pending') ...[
                  const PopupMenuItem(value: 'approve', child: Text('Approve')),
                  const PopupMenuItem(value: 'reject', child: Text('Reject')),
                ],
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleUserAction(User user, String action) async {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit screen
        break;
      case 'approve':
        final success = await context.read<UserProvider>().approveUser(user.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User berhasil diapprove')),
          );
        }
        break;
      case 'reject':
        final success = await context.read<UserProvider>().rejectUser(user.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User berhasil direject')),
          );
        }
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin menghapus user ini?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
            ],
          ),
        );

        if (confirm == true) {
          final success = await context.read<UserProvider>().deleteUser(user.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User berhasil dihapus')),
            );
          }
        }
        break;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red.shade100;
      case 'officers': return Colors.blue.shade100;
      case 'students': return Colors.green.shade100;
      default: return Colors.grey.shade100;
    }
  }

  Color _getStatusColor(User user) {
    if (user.role == 'officers') {
      switch (user.approvalStatus) {
        case 'approved': return Colors.green.shade100;
        case 'rejected': return Colors.red.shade100;
        default: return Colors.orange.shade100;
      }
    } else if (user.role == 'students') {
      return user.emailVerifiedAt != null ? Colors.green.shade100 : Colors.red.shade100;
    }
    return Colors.grey.shade100;
  }

  String _getStatusText(User user) {
    if (user.role == 'officers') {
      switch (user.approvalStatus) {
        case 'approved': return 'Approved';
        case 'rejected': return 'Rejected';
        default: return 'Pending';
      }
    } else if (user.role == 'students') {
      return user.emailVerifiedAt != null ? 'Verified' : 'Unverified';
    }
    return '-';
  }
}
