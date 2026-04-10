import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import '../screens/help_support_screen.dart';
import '../services/api_service.dart'; // Import ApiService

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? 'User'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.profilePicture != null
                  ? NetworkImage(ApiService.fixPhotoUrl(user!.profilePicture!)!)
                  : null,
              child: user?.profilePicture == null
                  ? Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),

          // Navigation Items
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              context.read<NavigationProvider>().setSelectedIndex(0); // Dashboard index
            },
          ),

          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Kelola Unit Kerja'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              context.read<NavigationProvider>().setSelectedIndex(1); // Assets index
            },
          ),

          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Kelola Peminjaman'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              context.read<NavigationProvider>().setSelectedIndex(2); // Kelola Peminjaman index
            },
          ),

          // Admin only items
          if (user?.role == 'admin') ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Kelola User'),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                Navigator.of(context).pushNamed('/admin-users');
              },
            ),
          ],

          // Officer/Admin items
          if (user?.role == 'officers' || user?.role == 'admin') ...[
            if (user?.role == 'admin') const Divider() else const Divider(),
            ListTile(
              leading: const Icon(Icons.class_),
              title: const Text('Kelola Kelas'),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                Navigator.of(context).pushNamed('/admin-classes');
              },
            ),
          ],

          const Divider(),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Navigate to settings
            },
          ),

          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.of(context).pop(); // Close drawer
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await authProvider.logout();
                if (context.mounted) {
                  // Clear navigation stack to AuthWrapper (home), which will show login screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
