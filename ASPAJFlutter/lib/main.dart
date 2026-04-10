import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/commodity_provider.dart';
import 'providers/borrowing_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/user_provider.dart';
import 'providers/class_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/assets_screen.dart';
import 'screens/borrowing_status_screen.dart';
import 'screens/borrowing_create_screen.dart';
import 'screens/return_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_classes_screen.dart';
import 'screens/checkout_screen.dart';
import 'widgets/navigation_drawer.dart';
import 'widgets/bottom_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommodityProvider()),
        ChangeNotifierProvider(create: (_) => BorrowingProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ClassProvider()),
      ],
      child: MaterialApp(
        title: 'Asset Borrowing App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.light,
          ),
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/assets': (context) => const AssetsScreen(),
          '/borrowing-status': (context) => const BorrowingStatusScreen(),
          '/borrowing-create': (context) => const BorrowingCreateScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin-users': (context) => const AdminUsersScreen(),
          '/admin-classes': (context) => const AdminClassesScreen(),
          '/checkout': (context) => const CheckoutScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/return') {
            final borrowing = settings.arguments as dynamic;
            return MaterialPageRoute(
              builder: (context) => ReturnScreen(borrowing: borrowing),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    print('AuthWrapper.initState: Initializing auth wrapper');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('AuthWrapper.initState: Post frame callback, checking auth status');
      context.read<AuthProvider>().checkAuthStatus();
      // Load cart after authentication check
      context.read<BorrowingProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('AuthWrapper.build: Building auth wrapper');
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print('AuthWrapper.build: Auth provider state - isLoading: ${authProvider.isLoading}, isAuthenticated: ${authProvider.isAuthenticated}');
        if (authProvider.isLoading) {
          print('AuthWrapper.build: Showing loading screen');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          print('AuthWrapper.build: User authenticated, showing main screen');
          return const MainScreen();
        }

        print('AuthWrapper.build: User not authenticated, showing login screen');
        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const AssetsScreen(),
      const BorrowingStatusScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final navigationProvider = context.watch<NavigationProvider>();
    final userRole = authProvider.user?.role;

    // Use Drawer for officers and admins, BottomNavigation for students
    final useDrawer = userRole == 'officers' || userRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Borrowing App'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      drawer: useDrawer ? const AppNavigationDrawer() : null,
      body: _screens[navigationProvider.selectedIndex],
      bottomNavigationBar: useDrawer
          ? null
          : AppBottomNavigation(
              currentIndex: navigationProvider.selectedIndex,
              onTap: (index) => navigationProvider.setSelectedIndex(index),
            ),
      floatingActionButton: navigationProvider.selectedIndex == 0 // Dashboard
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).pushNamed('/borrowing-create'),
              tooltip: 'Create New Borrowing',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
