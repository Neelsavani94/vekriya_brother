import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/karigar_service.dart';
import '../../services/upad_service.dart';

class UpadEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? upadData;

  const UpadEntryScreen({
    Key? key,
    this.upadData,
  }) : super(key: key);

  @override
  State<UpadEntryScreen> createState() => _UpadEntryScreenState();
}

class _UpadEntryScreenState extends State<UpadEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Services
  final UpadService _upadService = UpadService();
  final KarigarService _karigarService = KarigarService();

  // Controllers
  late TextEditingController _amountController;
  late TextEditingController _reasonController;
  late TextEditingController _notesController;

  // Form state
  String? _selectedKarigarId;
  Map<String, dynamic>? _selectedKarigar;
  String _selectedPaymentMode = 'cash';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isDataLoading = true;
  String? _error;

  // Data
  List<Map<String, dynamic>> _availableKarigars = [];

  final List<Map<String, dynamic>> _paymentModes = [
    {'id': 'cash', 'label': 'Cash', 'icon': Icons.money_rounded},
    {'id': 'upi', 'label': 'UPI', 'icon': Icons.phone_android_rounded},
    {'id': 'bank', 'label': 'Bank Transfer', 'icon': Icons.account_balance_rounded},
    {'id': 'cheque', 'label': 'Cheque', 'icon': Icons.receipt_long_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _amountController = TextEditingController();
    _reasonController = TextEditingController();
    _notesController = TextEditingController();
  }

  Future<void> _loadInitialData() async {
    try {
      final karigars = await _karigarService.getAvailableKarigars();
      setState(() {
        _availableKarigars = karigars;
        _isDataLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to load karigars';
        _isDataLoading = false;
      });
    }
  }

  bool get _isFormValid {
    return _selectedKarigarId != null &&
        _amountController.text.trim().isNotEmpty &&
        _reasonController.text.trim().isNotEmpty;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryLight,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectKarigar(Map<String, dynamic> karigar) {
    setState(() {
      _selectedKarigarId = karigar['id'];
      _selectedKarigar = karigar;
    });
    Navigator.pop(context);
  }

  Future<void> _saveUpadEntry() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final upadData = {
        'karigar_id': _selectedKarigarId!,
        'amount': double.parse(_amountController.text.trim()),
        'payment_date': _selectedDate.toIso8601String().split('T')[0],
        'payment_type': _selectedPaymentMode,
        'status': 'paid',
        'reason': _reasonController.text.trim(),
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      await _upadService.createUpadPayment(upadData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 2.w),
                Text('Upad payment saved successfully!'),
              ],
            ),
            backgroundColor: AppTheme.successLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${error.toString()}'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Pay Upad'),
        backgroundColor: AppTheme.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isDataLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryLight),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selection
                    _buildSectionCard(
                      title: 'Payment Date',
                      icon: Icons.calendar_today_rounded,
                      child: _buildDateSelector(),
                    ),

                    SizedBox(height: 2.h),

                    // Karigar Selection
                    _buildSectionCard(
                      title: 'Select Karigar',
                      icon: Icons.person_rounded,
                      child: _buildKarigarSelector(),
                    ),

                    SizedBox(height: 2.h),

                    // Payment Mode
                    _buildSectionCard(
                      title: 'Payment Mode',
                      icon: Icons.payment_rounded,
                      child: _buildPaymentModeSelector(),
                    ),

                    SizedBox(height: 2.h),

                    // Amount Input
                    _buildSectionCard(
                      title: 'Amount',
                      icon: Icons.currency_rupee_rounded,
                      child: _buildAmountInput(),
                    ),

                    SizedBox(height: 2.h),

                    // Reason Input
                    _buildSectionCard(
                      title: 'Reason',
                      icon: Icons.description_rounded,
                      child: _buildReasonInput(),
                    ),

                    SizedBox(height: 2.h),

                    // Notes (Optional)
                    _buildSectionCard(
                      title: 'Notes (Optional)',
                      icon: Icons.notes_rounded,
                      child: _buildNotesInput(),
                    ),

                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryLight, size: 18),
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerLight),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_rounded,
              color: AppTheme.primaryLight,
              size: 22,
            ),
            SizedBox(width: 3.w),
            Text(
              '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            Spacer(),
            Text(
              'Tap to change',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildKarigarSelector() {
    return GestureDetector(
      onTap: _showKarigarPicker,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedKarigar != null ? AppTheme.primaryLight : AppTheme.dividerLight,
            width: _selectedKarigar != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _selectedKarigar != null
                  ? Center(
                      child: Text(
                        _getInitials(_selectedKarigar!['full_name'] ?? ''),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person_add_rounded,
                      color: AppTheme.primaryLight,
                    ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedKarigar?['full_name'] ?? 'Select a Karigar',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _selectedKarigar != null
                          ? AppTheme.textPrimaryLight
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                  if (_selectedKarigar != null)
                    Text(
                      _selectedKarigar!['phone'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textLabelLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  void _showKarigarPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 1.5.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.dividerLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Row(
                children: [
                  Text(
                    'Select Karigar',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                itemCount: _availableKarigars.length,
                itemBuilder: (context, index) {
                  final karigar = _availableKarigars[index];
                  final isSelected = karigar['id'] == _selectedKarigarId;

                  return ListTile(
                    onTap: () => _selectKarigar(karigar),
                    leading: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryLight
                            : AppTheme.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(karigar['full_name'] ?? ''),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppTheme.primaryLight,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      karigar['full_name'] ?? '',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryLight,
                      ),
                    ),
                    subtitle: Text(
                      karigar['phone'] ?? '',
                      style: GoogleFonts.poppins(
                        color: AppTheme.textSecondaryLight,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: AppTheme.primaryLight)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentModeSelector() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.5.h,
      children: _paymentModes.map((mode) {
        final isSelected = _selectedPaymentMode == mode['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMode = mode['id'] as String;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryLight : AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  mode['icon'] as IconData,
                  size: 18,
                  color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                ),
                SizedBox(width: 2.w),
                Text(
                  mode['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppTheme.textLabelLight,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 4.w, right: 2.w),
          child: Text(
            '₹',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryLight,
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 1.h),
      ),
    );
  }

  Widget _buildReasonInput() {
    return TextFormField(
      controller: _reasonController,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: AppTheme.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: 'e.g., Weekly advance, Festival bonus...',
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      ),
    );
  }

  Widget _buildNotesInput() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: AppTheme.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: 'Add any additional notes...',
        contentPadding: EdgeInsets.all(4.w),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        border: Border(top: BorderSide(color: AppTheme.dividerLight)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isFormValid && !_isLoading ? _saveUpadEntry : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successLight,
              disabledBackgroundColor: AppTheme.dividerLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_rounded, color: Colors.white),
                      SizedBox(width: 2.w),
                      Text(
                        'Pay Upad',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
