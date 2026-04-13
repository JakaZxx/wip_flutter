import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/borrowing_provider.dart';
import '../models/borrowing_item.dart';
import '../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _borrowDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _borrowTimeController = TextEditingController();
  final TextEditingController _returnTimeController = TextEditingController();

  DateTime? _borrowDate;
  DateTime? _returnDate;
  TimeOfDay? _borrowTime;
  TimeOfDay? _returnTime;

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().loadCart();
    });
  }

  void _initializeDefaults() {
    _borrowDate = DateTime.now();
    _borrowDateController.text = DateFormat('yyyy-MM-dd').format(_borrowDate!);
    
    _returnDate = DateTime.now().add(const Duration(days: 7));
    _returnDateController.text = DateFormat('yyyy-MM-dd').format(_returnDate!);

    _borrowTime = TimeOfDay.now();
    _borrowTimeController.text = _formatTime(_borrowTime!);

    _returnTime = const TimeOfDay(hour: 16, minute: 0);
    _returnTimeController.text = _formatTime(_returnTime!);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<BorrowingProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              if (provider.cartItems.isEmpty)
                SliverFillRemaining(child: _buildEmptyCart())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  sliver: SliverToBoxAdapter(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('SUMMARY PESANAN'),
                          const SizedBox(height: 16),
                          ...provider.cartItems.map((item) => CheckoutItemCardPremium(
                            item: item,
                            onRemove: () => provider.removeFromCart(item.commodityId),
                            onUpdateQuantity: (q) => provider.updateCartItemQuantity(item.commodityId, q),
                          )),
                          const SizedBox(height: 32),
                          _buildSectionLabel('DETAIL PEMINJAMAN'),
                          const SizedBox(height: 16),
                          _buildFormFields(),
                          const SizedBox(height: 48),
                          _buildSubmitButton(provider),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: const Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.check_circle_outline_rounded, size: 160, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: Text(
          'CHECKOUT',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: 2),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8), letterSpacing: 1.5),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildInputField(
          controller: _purposeController,
          label: 'Tujuan Peminjaman',
          hint: 'Jelaskan alasan peminjaman Anda...',
          icon: Icons.notes_rounded,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildInputField(
                controller: _borrowDateController,
                label: 'Mulai Pinjam',
                readOnly: true,
                onTap: () => _selectDate(true),
                icon: Icons.calendar_today_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInputField(
                controller: _borrowTimeController,
                label: 'Jam',
                readOnly: true,
                onTap: () => _selectTime(true),
                icon: Icons.access_time_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildInputField(
                controller: _returnDateController,
                label: 'Estimasi Kembali',
                readOnly: true,
                onTap: () => _selectDate(false),
                icon: Icons.event_available_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInputField(
                controller: _returnTimeController,
                label: 'Jam',
                readOnly: true,
                onTap: () => _selectTime(false),
                icon: Icons.access_time_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: const Color(0xFFCBD5E1), fontSize: 13),
            prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Field ini wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BorrowingProvider provider) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), AppTheme.primaryBlue]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : () => _submitBorrowing(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: provider.isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                'PLACE REQUEST',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2.0),
              ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
            child: FaIcon(FontAwesomeIcons.cartShopping, size: 80, color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 32),
          Text('Waduh, Masih Kosong!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text('Sepertinya belum ada aset yang dipilih.', style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
          const SizedBox(height: 48),
          SizedBox(
            width: 220,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('KEMBALI KE KATALOG', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isBorrow) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBorrow ? _borrowDate ?? DateTime.now() : _returnDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isBorrow) {
          _borrowDate = picked;
          _borrowDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _returnDate = picked;
          _returnDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _selectTime(bool isBorrow) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBorrow ? _borrowTime ?? TimeOfDay.now() : _returnTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isBorrow) {
          _borrowTime = picked;
          _borrowTimeController.text = _formatTime(picked);
        } else {
          _returnTime = picked;
          _returnTimeController.text = _formatTime(picked);
        }
      });
    }
  }

  Future<void> _submitBorrowing() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BorrowingProvider>();
    
    final payload = {
      'borrow_date': _borrowDateController.text,
      'borrow_time': _borrowTimeController.text,
      'return_date': _returnDateController.text,
      'return_time': _returnTimeController.text,
      'tujuan': _purposeController.text,
      'items': provider.cartItems.map((e) => {
        'commodity_id': e.commodityId,
        'quantity': e.quantity,
      }).toList(),
    };

    try {
      await provider.createBorrowing(payload);
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.dangerRed, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('Request ID Sent!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Permintaan Anda telah kami teruskan ke sistem verifikasi.', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('LIHAT STATUS PINJAMAN', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _borrowDateController.dispose();
    _returnDateController.dispose();
    _borrowTimeController.dispose();
    _returnTimeController.dispose();
    super.dispose();
  }
}

class CheckoutItemCardPremium extends StatelessWidget {
  final BorrowingItem item;
  final VoidCallback onRemove;
  final Function(int) onUpdateQuantity;

  const CheckoutItemCardPremium({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Icon(Icons.inventory_2_rounded, color: AppTheme.primaryBlue, size: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.displayName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text('Kondisi: ${item.condition ?? 'Sangat Baik'}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8))),
                ],
              ),
            ),
            _buildQuantityController(),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityController() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepButton(Icons.remove_rounded, item.quantity > 1 ? () => onUpdateQuantity(item.quantity - 1) : null),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('${item.quantity}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14)),
          ),
          _buildStepButton(Icons.add_rounded, () => onUpdateQuantity(item.quantity + 1)),
        ],
      ),
    );
  }

  Widget _buildStepButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: onTap == null ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B)),
      ),
    );
  }
}


