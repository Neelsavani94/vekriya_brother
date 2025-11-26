import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/daily_work_service.dart';
import '../../services/karigar_service.dart';

class DailyWorkEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? workEntryData;

  const DailyWorkEntryScreen({
    Key? key,
    this.workEntryData,
  }) : super(key: key);

  @override
  State<DailyWorkEntryScreen> createState() => _DailyWorkEntryScreenState();
}

class _DailyWorkEntryScreenState extends State<DailyWorkEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Services
  final DailyWorkService _dailyWorkService = DailyWorkService();
  final KarigarService _karigarService = KarigarService();

  // Controllers
  late TextEditingController _piecesController;
  late TextEditingController _rateController;
  late TextEditingController _notesController;

  // Form state
  String? _selectedKarigarId;
  Map<String, dynamic>? _selectedKarigar;
  DateTime _selectedDate = DateTime.now();
  double _totalEarnings = 0.0;
  bool _isLoading = false;
  bool _isDataLoading = true;
  String? _error;

  // Data
  List<Map<String, dynamic>> _availableKarigars = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  @override
  void dispose() {
    _piecesController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _piecesController = TextEditingController();
    _rateController = TextEditingController();
    _notesController = TextEditingController();

    _piecesController.addListener(_calculateEarnings);
    _rateController.addListener(_calculateEarnings);
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

  void _calculateEarnings() {
    final pieces = int.tryParse(_piecesController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;

    setState(() {
      _totalEarnings = pieces * rate;
    });
  }

  bool get _isFormValid {
    return _selectedKarigarId != null &&
        _piecesController.text.trim().isNotEmpty &&
        _rateController.text.trim().isNotEmpty;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
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
      if (karigar['salary_per_piece'] != null) {
        _rateController.text = karigar['salary_per_piece'].toString();
      }
    });
    Navigator.pop(context);
  }

  Future<void> _saveWorkEntry() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final workEntryData = {
        'karigar_id': _selectedKarigarId!,
        'work_date': _selectedDate.toIso8601String().split('T')[0],
        'work_type': 'piece_work',
        'pieces_completed': int.parse(_piecesController.text.trim()),
        'rate_per_piece': double.parse(_rateController.text.trim()),
        'status': 'completed',
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      await _dailyWorkService.createDailyWorkEntry(workEntryData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 2.w),
                Text('Work entry saved successfully!'),
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
        title: Text('Add Daily Work'),
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
                      title: 'Work Date',
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

                    // Work Details
                    _buildSectionCard(
                      title: 'Work Details',
                      icon: Icons.work_rounded,
                      child: _buildWorkDetails(),
                    ),

                    SizedBox(height: 2.h),

                    // Earnings Summary
                    _buildEarningsSummary(),

                    SizedBox(height: 2.h),

                    // Notes
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
              _isToday(_selectedDate) ? 'Today' : 'Tap to change',
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
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
                      '₹${_selectedKarigar!['salary_per_piece'] ?? 0}/piece',
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
                      '₹${karigar['salary_per_piece'] ?? 0}/piece',
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

  Widget _buildWorkDetails() {
    return Column(
      children: [
        // Pieces Input
        _buildInputField(
          controller: _piecesController,
          label: 'Number of Pieces',
          hint: 'Enter pieces completed',
          keyboardType: TextInputType.number,
          prefix: Icon(Icons.inventory_2_rounded, color: AppTheme.textSecondaryLight, size: 20),
        ),
        SizedBox(height: 2.h),
        // Rate Input
        _buildInputField(
          controller: _rateController,
          label: 'Rate per Piece (₹)',
          hint: 'Enter rate per piece',
          keyboardType: TextInputType.number,
          prefix: Icon(Icons.currency_rupee_rounded, color: AppTheme.textSecondaryLight, size: 20),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondaryLight,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successLight,
            AppTheme.successLight.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successLight.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          SizedBox(width: 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Earnings',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                '₹${_totalEarnings.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
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
        hintText: 'Add any notes about this work...',
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
            onPressed: _isFormValid && !_isLoading ? _saveWorkEntry : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
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
                      Icon(Icons.check_rounded, color: Colors.white),
                      SizedBox(width: 2.w),
                      Text(
                        'Save Work Entry',
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
