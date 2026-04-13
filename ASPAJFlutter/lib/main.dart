import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/commodity_provider.dart';
import 'providers/borrowing_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/user_provider.dart';
import 'providers/class_provider.dart';
import 'auth/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'student/assets_screen.dart';
import 'officer/borrowing_status_screen.dart';
import 'student/borrowing_create_screen.dart';
import 'officer/return_screen.dart';
import 'screens/profile_screen.dart';
import 'admin/admin_users_screen.dart';
import 'admin/admin_classes_screen.dart';
import 'student/checkout_screen.dart';
import 'widgets/navigation_drawer.dart';
import 'widgets/bottom_navigation.dart';
import 'theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
        title: '4llAset',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: ThemeData.dark().copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
      context.read<BorrowingProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const FaIcon(FontAwesomeIcons.shieldHalved, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: 32),
                  Text('4LL ASET', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 4)),
                  const SizedBox(height: 8),
                  Text('Mengamankan Infrastruktur...', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
                  const SizedBox(height: 48),
                  const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                ],
              ),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const MainScreen();
        }

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

    final useDrawer = userRole == 'officers' || userRole == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      drawer: useDrawer ? const AppNavigationDrawer() : null,
      body: _screens[navigationProvider.selectedIndex],
      bottomNavigationBar: useDrawer
          ? null
          : AppBottomNavigation(
              currentIndex: navigationProvider.selectedIndex,
              onTap: (index) => navigationProvider.setSelectedIndex(index),
            ),
      floatingActionButton: navigationProvider.selectedIndex == 1 && userRole == 'students'
          ? Container(
              height: 64, width: 64,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed('/borrowing-create'),
                  borderRadius: BorderRadius.circular(20),
                  child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 24),
                ),
              ),
            )
          : null,
    );
  }
}
