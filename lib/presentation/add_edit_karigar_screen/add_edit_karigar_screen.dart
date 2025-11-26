import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/karigar_service.dart';

class AddEditKarigarScreen extends StatefulWidget {
  final Map<String, dynamic>? karigarData;

  const AddEditKarigarScreen({
    Key? key,
    this.karigarData,
  }) : super(key: key);

  @override
  State<AddEditKarigarScreen> createState() => _AddEditKarigarScreenState();
}

class _AddEditKarigarScreenState extends State<AddEditKarigarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final KarigarService _karigarService = KarigarService();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _employeeIdController;
  late TextEditingController _pieceRateController;
  late TextEditingController _addressController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscController;

  // Form state
  DateTime? _joiningDate;
  String _selectedSkillLevel = 'beginner';
  XFile? _selectedImage;
  bool _isLoading = false;
  String? _error;

  // Validation
  String? _nameError;
  String? _mobileError;
  String? _pieceRateError;

  final List<Map<String, String>> _skillLevels = [
    {'id': 'beginner', 'label': 'Beginner'},
    {'id': 'intermediate', 'label': 'Intermediate'},
    {'id': 'advanced', 'label': 'Advanced'},
    {'id': 'expert', 'label': 'Expert'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadKarigarData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _employeeIdController.dispose();
    _pieceRateController.dispose();
    _addressController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _employeeIdController = TextEditingController();
    _pieceRateController = TextEditingController();
    _addressController = TextEditingController();
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _ifscController = TextEditingController();
  }

  void _loadKarigarData() {
    if (widget.karigarData != null) {
      final data = widget.karigarData!;
      _nameController.text = data['name'] ?? '';
      _mobileController.text = data['mobile'] ?? '';
      _employeeIdController.text = data['employee_id'] ?? '';
      _pieceRateController.text = data['pieceRate']?.toString() ?? '';
      _selectedSkillLevel = data['skill_level'] ?? 'beginner';
      _joiningDate = data['joiningDate'] != null
          ? DateTime.parse(data['joiningDate'])
          : null;
      _addressController.text = data['address'] ?? '';
    }
  }

  bool get _isEditing => widget.karigarData != null;

  String get _screenTitle => _isEditing ? 'Edit Karigar' : 'Add New Karigar';

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _mobileController.text.trim().length == 10 &&
        _pieceRateController.text.trim().isNotEmpty &&
        _joiningDate != null &&
        _nameError == null &&
        _mobileError == null &&
        _pieceRateError == null;
  }

  void _validateName(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _nameError = 'Name is required';
      } else if (value.trim().length < 2) {
        _nameError = 'Name is too short';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateMobile(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _mobileError = 'Mobile is required';
      } else if (value.trim().length != 10) {
        _mobileError = 'Enter 10-digit number';
      } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
        _mobileError = 'Invalid mobile number';
      } else {
        _mobileError = null;
      }
    });
  }

  void _validatePieceRate(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _pieceRateError = 'Rate is required';
      } else {
        final rate = double.tryParse(value.trim());
        if (rate == null || rate <= 0) {
          _pieceRateError = 'Enter valid rate';
        } else {
          _pieceRateError = null;
        }
      }
    });
  }

  Future<void> _selectJoiningDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(2020),
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
        _joiningDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.dividerLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Choose Photo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: _buildPhotoOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () => _getImage(ImageSource.camera),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _buildPhotoOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => _getImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerLight),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryLight),
            SizedBox(height: 1.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  Future<void> _saveKarigar() async {
    _validateName(_nameController.text);
    _validateMobile(_mobileController.text);
    _validatePieceRate(_pieceRateController.text);

    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: AppTheme.warningLight,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final karigarData = {
        'full_name': _nameController.text.trim(),
        'phone': _mobileController.text.trim(),
        'employee_id': _employeeIdController.text.trim().isNotEmpty
            ? _employeeIdController.text.trim()
            : 'EMP${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        'salary_per_piece': double.parse(_pieceRateController.text.trim()),
        'skill_level': _selectedSkillLevel,
        'joining_date': _joiningDate!.toIso8601String().split('T')[0],
        'address': _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        'is_active': true,
      };

      // Add bank details if provided
      if (_accountNumberController.text.trim().isNotEmpty) {
        karigarData['bank_details'] = {
          'account_number': _accountNumberController.text.trim(),
          'ifsc': _ifscController.text.trim(),
          'bank_name': _bankNameController.text.trim(),
        };
      }

      if (_isEditing) {
        await _karigarService.updateKarigar(
          widget.karigarData!['id'],
          karigarData,
        );
      } else {
        await _karigarService.createKarigar(karigarData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 2.w),
                Text(_isEditing ? 'Karigar updated!' : 'Karigar added successfully!'),
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
          content: Text('Failed: ${error.toString()}'),
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
        title: Text(_screenTitle),
        backgroundColor: AppTheme.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Photo
              _buildProfilePhotoSection(),

              SizedBox(height: 3.h),

              // Basic Info
              _buildSectionCard(
                title: 'Basic Information',
                icon: Icons.person_rounded,
                child: _buildBasicInfoSection(),
              ),

              SizedBox(height: 2.h),

              // Work Details
              _buildSectionCard(
                title: 'Work Details',
                icon: Icons.work_rounded,
                child: _buildWorkDetailsSection(),
              ),

              SizedBox(height: 2.h),

              // Address (Optional)
              _buildSectionCard(
                title: 'Address (Optional)',
                icon: Icons.location_on_rounded,
                child: _buildAddressSection(),
              ),

              SizedBox(height: 2.h),

              // Bank Details (Optional)
              _buildSectionCard(
                title: 'Bank Details (Optional)',
                icon: Icons.account_balance_rounded,
                child: _buildBankDetailsSection(),
              ),

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryLight, width: 2),
              ),
              child: _selectedImage != null
                  ? ClipOval(
                      child: Image.network(
                        _selectedImage!.path,
                        fit: BoxFit.cover,
                        width: 28.w,
                        height: 28.w,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: AppTheme.primaryLight,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name *',
          hint: 'Enter karigar name',
          icon: Icons.person_outline_rounded,
          onChanged: _validateName,
          errorText: _nameError,
        ),
        SizedBox(height: 2.h),
        _buildTextField(
          controller: _mobileController,
          label: 'Mobile Number *',
          hint: '10-digit mobile number',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          onChanged: _validateMobile,
          errorText: _mobileError,
          maxLength: 10,
        ),
        SizedBox(height: 2.h),
        _buildTextField(
          controller: _employeeIdController,
          label: 'Employee ID (Optional)',
          hint: 'Auto-generated if empty',
          icon: Icons.badge_rounded,
        ),
      ],
    );
  }

  Widget _buildWorkDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _pieceRateController,
          label: 'Rate per Piece (₹) *',
          hint: 'Enter piece rate',
          icon: Icons.currency_rupee_rounded,
          keyboardType: TextInputType.number,
          onChanged: _validatePieceRate,
          errorText: _pieceRateError,
        ),
        SizedBox(height: 2.h),
        
        // Joining Date
        Text(
          'Joining Date *',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondaryLight,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _selectJoiningDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _joiningDate != null ? AppTheme.primaryLight : AppTheme.dividerLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppTheme.textSecondaryLight,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  _joiningDate != null
                      ? '${_joiningDate!.day} ${_getMonthName(_joiningDate!.month)} ${_joiningDate!.year}'
                      : 'Select joining date',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: _joiningDate != null
                        ? AppTheme.textPrimaryLight
                        : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 2.h),
        
        // Skill Level
        Text(
          'Skill Level',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondaryLight,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _skillLevels.map((level) {
            final isSelected = _selectedSkillLevel == level['id'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSkillLevel = level['id']!;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryLight : AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
                  ),
                ),
                child: Text(
                  level['label']!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildAddressSection() {
    return TextFormField(
      controller: _addressController,
      maxLines: 3,
      style: GoogleFonts.poppins(
        fontSize: 15,
        color: AppTheme.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: 'Enter full address...',
        contentPadding: EdgeInsets.all(4.w),
      ),
    );
  }

  Widget _buildBankDetailsSection() {
    return Column(
      children: [
        _buildTextField(
          controller: _bankNameController,
          label: 'Bank Name',
          hint: 'Enter bank name',
          icon: Icons.account_balance_rounded,
        ),
        SizedBox(height: 2.h),
        _buildTextField(
          controller: _accountNumberController,
          label: 'Account Number',
          hint: 'Enter account number',
          icon: Icons.credit_card_rounded,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 2.h),
        _buildTextField(
          controller: _ifscController,
          label: 'IFSC Code',
          hint: 'Enter IFSC code',
          icon: Icons.code_rounded,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
    String? errorText,
    int? maxLength,
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
          maxLength: maxLength,
          onChanged: onChanged,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: AppTheme.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            prefixIcon: Icon(icon, color: AppTheme.textSecondaryLight, size: 20),
            errorText: errorText,
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
        ),
      ],
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
            onPressed: _isLoading ? null : _saveKarigar,
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
                      Icon(
                        _isEditing ? Icons.check_rounded : Icons.person_add_rounded,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _isEditing ? 'Update Karigar' : 'Add Karigar',
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
