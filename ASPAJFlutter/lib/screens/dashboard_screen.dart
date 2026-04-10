import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/navigation_provider.dart';
import '../models/user.dart';
import '../models/dashboard_stats.dart';
import 'login_screen.dart';

// Helper function to safely parse dynamic values to double.
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    try {
      await dashboardProvider.fetchDashboardStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      dashboardProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user.name}!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildDashboardContent(user, dashboardProvider.dashboardStats),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(User user, DashboardStats? stats) {
    if (stats == null) {
      return const Center(child: Text('Data dashboard tidak tersedia.'));
    }

    if (user.isAdmin) {
      return _buildAdminDashboard(stats);
    } else if (user.isOfficer) {
      return _buildOfficerDashboard(stats);
    } else if (user.isStudent) {
      return _buildStudentDashboard(stats);
    } else {
      return const Center(child: Text('Role pengguna tidak dikenali.'));
    }
  }

  // ===========================================================================
  // ADMIN DASHBOARD
  // ===========================================================================
  Widget _buildAdminDashboard(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              title: 'Total Pengguna',
              value: stats.totalUsers?.toString() ?? '0',
              icon: FontAwesomeIcons.users,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Total Aset',
              value: stats.totalAssets?.toString() ?? '0',
              icon: FontAwesomeIcons.boxArchive,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Persetujuan Tertunda',
              value: stats.pendingUsersCount?.toString() ?? '0',
              icon: FontAwesomeIcons.userClock,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Total Peminjaman',
              value: stats.totalBorrowings?.toString() ?? '0',
              icon: FontAwesomeIcons.retweet,
              color: Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Actions
        _DashboardSection(
          title: 'Aksi Cepat',
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ActionCard(
                title: 'Kelola Pengguna',
                icon: FontAwesomeIcons.usersCog,
                onTap: () => Navigator.of(context).pushNamed('/admin-users'),
              ),
              _ActionCard(
                title: 'Kelola Aset',
                icon: FontAwesomeIcons.boxesStacked,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(1),
              ),
              _ActionCard(
                title: 'Kelola Kelas',
                icon: FontAwesomeIcons.school,
                onTap: () => Navigator.of(context).pushNamed('/admin-classes'),
              ),
              _ActionCard(
                title: 'Riwayat Pinjam',
                icon: FontAwesomeIcons.history,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Charts
        _DashboardSection(
          title: 'Statistik Visual',
          child: Column(
            children: [
              _ChartCard(title: 'Pertumbuhan Pengguna', chart: _buildLineChart(stats.userGrowth)),
              const SizedBox(height: 16),
              _ChartCard(title: 'Distribusi Aset', chart: _buildBarChart(stats.assetDistribution)),
              const SizedBox(height: 16),
              _ChartCard(title: 'Status Aset', chart: _buildDoughnutChart(stats.assetStatus)),
            ],
          )
        ),
      ],
    );
  }

  // ===========================================================================
  // OFFICER DASHBOARD
  // ===========================================================================
  Widget _buildOfficerDashboard(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              title: 'Peminjaman Aktif',
              value: stats.activeBorrowingsCount?.toString() ?? '0',
              icon: FontAwesomeIcons.bookOpen,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Total Aset Jurusan',
              value: stats.totalAssets?.toString() ?? '0',
              icon: FontAwesomeIcons.box,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Menunggu Persetujuan',
              value: stats.pendingRequestsCount?.toString() ?? '0',
              icon: FontAwesomeIcons.clock,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Jatuh Tempo',
              value: stats.overdueBorrowingsCount?.toString() ?? '0',
              icon: FontAwesomeIcons.undoAlt,
              color: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Actions
        _DashboardSection(
          title: 'Aksi Cepat',
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ActionCard(
                title: 'Kelola Aset',
                icon: FontAwesomeIcons.boxesStacked,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(1),
              ),
              _ActionCard(
                title: 'Proses Peminjaman',
                icon: FontAwesomeIcons.tasks,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(2),
              ),
              _ActionCard(
                title: 'Buat Peminjaman',
                icon: FontAwesomeIcons.plusCircle,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(1), // Navigate to assets to create borrowing
              ),
              _ActionCard(
                title: 'Kelola Kelas',
                icon: FontAwesomeIcons.school,
                onTap: () => Navigator.of(context).pushNamed('/admin-classes'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Recent Requests
        _DashboardSection(
          title: 'Permintaan Peminjaman Baru',
          child: _buildRequestList(stats.newRequests),
        ),
      ],
    );
  }

  // ===========================================================================
  // STUDENT DASHBOARD
  // ===========================================================================
  Widget _buildStudentDashboard(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _StatCard(
              title: 'Aset Tersedia',
              value: stats.totalAvailableAssets?.toString() ?? '0',
              icon: FontAwesomeIcons.boxOpen,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Sedang Dipinjam',
              value: stats.myActiveBorrowingsCount?.toString() ?? '0',
              icon: FontAwesomeIcons.shoppingBasket,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Pending',
              value: stats.pendingBorrowingsCount?.toString() ?? '0',
              icon: FontAwesomeIcons.hourglassHalf,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Jatuh Tempo',
              value: stats.approvedOrOverdueBorrowingsCount?.toString() ?? '0',
              icon: FontAwesomeIcons.exclamationTriangle,
              color: Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Actions
        _DashboardSection(
          title: 'Aksi Cepat',
          child: Column(
            children: [
              _ActionCard(
                title: 'Pinjam Aset',
                icon: FontAwesomeIcons.plusCircle,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(1), // Navigate to assets/commodities
              ),
              const SizedBox(height: 12),
              _ActionCard(
                title: 'Riwayat & Pengembalian',
                icon: FontAwesomeIcons.history,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(2), // Navigate to borrowing status
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Reminder
        if (stats.upcomingDueBorrowing != null)
          _ReminderCard(data: stats.upcomingDueBorrowing!),
        
        const SizedBox(height: 24),

        // Tips Card
        const _TipsCard(),
      ],
    );
  }

  // ===========================================================================
  // SHARED WIDGETS
  // ===========================================================================

  Widget _buildLineChart(ChartData? chartData) {
    if (chartData == null) return const Center(child: Text('Data grafik tidak tersedia'));
    final labels = chartData.labels;
    final data = chartData.data;

    if (labels.isEmpty || data.isEmpty) return const Center(child: Text('Data tidak cukup untuk ditampilkan.'));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
            isCurved: true,
            color: Colors.blue,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, dynamic>? chartData) {
    if (chartData == null) return const Center(child: Text('Data grafik tidak tersedia'));
    final labels = List<String>.from(chartData['labels'] ?? []);
    final totalData = (chartData['total_data'] as List<dynamic>? ?? []).map((e) => _parseDouble(e) ?? 0.0).toList();
    final availableData = (chartData['available_data'] as List<dynamic>? ?? []).map((e) => _parseDouble(e) ?? 0.0).toList();

    if (labels.isEmpty) return const Center(child: Text('Data tidak cukup untuk ditampilkan.'));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(labels.length, (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(toY: totalData.length > index ? totalData[index] : 0, color: Colors.green, width: 15),
            BarChartRodData(toY: availableData.length > index ? availableData[index] : 0, color: Colors.grey, width: 15),
          ],
        )),
      ),
    );
  }

  Widget _buildDoughnutChart(Map<String, dynamic>? chartData) {
    if (chartData == null) return const Center(child: Text('Data grafik tidak tersedia'));
    final sections = <PieChartSectionData>[];
    final colors = {'available': Colors.green, 'borrowed': Colors.blue, 'maintenance': Colors.orange, 'damaged': Colors.red};

    chartData.forEach((key, value) {
      final doubleValue = _parseDouble(value) ?? 0.0;
      sections.add(PieChartSectionData(
        color: colors[key] ?? Colors.grey,
        value: doubleValue,
        title: '${doubleValue.toInt()}',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    });

    return PieChart(PieChartData(sections: sections, centerSpaceRadius: 40));
  }

  Widget _buildRequestList(List<RecentRequest>? requests) {
    if (requests == null || requests.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text('Tidak ada permintaan baru.'),
      ));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final request = requests[index];
        return ListTile(
          title: Text(request.studentName),
          subtitle: Text(request.itemsSummary),
          trailing: ElevatedButton(
            child: const Text('Lihat'),
            onPressed: () => context.read<NavigationProvider>().setSelectedIndex(2),
          ),
        );
      },
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _DashboardSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  const _ChartCard({required this.title, required this.chart});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            SizedBox(height: 150, child: chart),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ReminderCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(FontAwesomeIcons.bell, color: Colors.amber.shade800),
            const SizedBox(width: 16),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Pengingat: Peminjaman ',
                  children: [
                    TextSpan(
                      text: data['item_name'] as String? ?? 'barang',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' akan jatuh tempo pada '),
                    TextSpan(
                      text: data['due_date'] as String? ?? 'segera',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.cyan.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.cyan.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(FontAwesomeIcons.lightbulb, color: Colors.cyan.shade800),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Tips: Selalu periksa kelengkapan aset sebelum dan sesudah meminjam. Laporkan jika ada kerusakan.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
