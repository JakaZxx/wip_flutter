import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../providers/borrowing_provider.dart';
import '../models/borrowing.dart';
import '../theme/app_theme.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().fetchBorrowings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          Consumer<BorrowingProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                );
              }

              if (provider.borrowings.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(FontAwesomeIcons.circleExclamation, size: 60, color: Colors.grey.withValues(alpha: 0.3)),
                        const SizedBox(height: 24),
                        Text('TIDAK ADA AKTIVITAS', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 2)),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildLogItem(provider.borrowings[index]),
                    itemCount: provider.borrowings.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text('AKTIVITAS SISTEM', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: Stack(
            children: [
              Positioned(
                right: -30, bottom: -30,
                child: Opacity(opacity: 0.1, child: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 160, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildLogItem(Borrowing activity) {
    final dateStr = activity.borrowDate != null ? DateFormat('dd MMM yyyy').format(activity.borrowDate!) : 'Unknown';
    
    Color statusColor = Colors.orange;
    String statusText = 'PROSES';
    IconData icon = FontAwesomeIcons.clock;

    if (activity.status == 'approved') {
      statusColor = const Color(0xFF3B82F6);
      statusText = 'DIPINJAM';
      icon = FontAwesomeIcons.handHolding;
    } else if (activity.status == 'returned') {
      statusColor = const Color(0xFF10B981);
      statusText = 'KEMBALI';
      icon = FontAwesomeIcons.circleCheck;
    } else if (activity.status == 'rejected') {
      statusColor = const Color(0xFFEF4444);
      statusText = 'DITOLAK';
      icon = FontAwesomeIcons.circleXmark;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateStr, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(statusText, style: GoogleFonts.outfit(color: statusColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(activity.student?.name ?? 'Identitas Terenkripsi', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                    const SizedBox(height: 4),
                    Text(activity.tujuan ?? 'Peminjaman Inventaris', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        FaIcon(icon, size: 12, color: statusColor),
                        const SizedBox(width: 8),
                        Text(activity.status.toUpperCase(), style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 1.5)),
                        const Spacer(),
                        Text('ID: #${activity.id.toString().padLeft(4, '0')}', style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFFCBD5E1), fontWeight: FontWeight.bold)),
                      ],
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
