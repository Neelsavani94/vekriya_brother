import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/karigar_service.dart';
import './widgets/address_section.dart';
import './widgets/bank_details_section.dart';
import './widgets/personal_details_section.dart';
import './widgets/profile_photo_section.dart';
import './widgets/work_details_section.dart';

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
  late TextEditingController _emailController;
  late TextEditingController _employeeIdController;
  late TextEditingController _pieceRateController;
  late TextEditingController _baseSalaryController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscController;
  late TextEditingController _bankNameController;
  late TextEditingController _branchController;

  // Form state
  String? _selectedMachine;
  String _selectedSkillLevel = 'beginner';
  List<String> _selectedSpecializations = [];
  DateTime? _joiningDate;
  DateTime? _dateOfBirth;
  XFile? _selectedImage;
  bool _isLoading = false;
  bool _isDraftSaved = false;
  String? _error;

  // Validation errors
  String? _nameError;
  String? _mobileError;
  String? _employeeIdError;
  String? _pieceRateError;
  String? _joiningDateError;

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
    _emailController.dispose();
    _employeeIdController.dispose();
    _pieceRateController.dispose();
    _baseSalaryController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _branchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _emailController = TextEditingController();
    _employeeIdController = TextEditingController();
    _pieceRateController = TextEditingController();
    _baseSalaryController = TextEditingController();
    _addressController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _accountNumberController = TextEditingController();
    _ifscController = TextEditingController();
    _bankNameController = TextEditingController();
    _branchController = TextEditingController();
  }

  void _loadKarigarData() {
    if (widget.karigarData != null) {
      final data = widget.karigarData!;
      _nameController.text = data['name'] ?? '';
      _mobileController.text = data['mobile'] ?? '';
      _emailController.text = data['email'] ?? '';
      _employeeIdController.text = data['employee_id'] ?? '';
      _pieceRateController.text = data['pieceRate']?.toString() ?? '';
      _baseSalaryController.text = data['base_salary']?.toString() ?? '';
      _selectedSkillLevel = data['skill_level'] ?? 'beginner';
      _joiningDate = data['joiningDate'] != null
          ? DateTime.parse(data['joiningDate'])
          : null;
      _dateOfBirth = data['date_of_birth'] != null
          ? DateTime.parse(data['date_of_birth'])
          : null;
      _addressController.text = data['address'] ?? '';
      _emergencyContactController.text = data['emergency_contact'] ?? '';

      // Handle specializations
      if (data['specialization'] is List) {
        _selectedSpecializations = List<String>.from(data['specialization']);
      }

      // Handle bank details
      if (data['bank_details'] != null) {
        final bankDetails = data['bank_details'] as Map<String, dynamic>;
        _accountNumberController.text = bankDetails['account_number'] ?? '';
        _ifscController.text = bankDetails['ifsc'] ?? '';
        _bankNameController.text = bankDetails['bank_name'] ?? '';
        _branchController.text = bankDetails['branch'] ?? '';
      }
    }
  }

  bool get _isEditing => widget.karigarData != null;

  String get _screenTitle => _isEditing
      ? 'Edit ${widget.karigarData!['name'] ?? 'Karigar'}'
      : 'Add Karigar';

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _mobileController.text.trim().length == 10 &&
        _employeeIdController.text.trim().isNotEmpty &&
        _pieceRateController.text.trim().isNotEmpty &&
        _joiningDate != null &&
        _nameError == null &&
        _mobileError == null &&
        _employeeIdError == null &&
        _pieceRateError == null &&
        _joiningDateError == null;
  }

  void _validateName(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _nameError = 'Name is required';
      } else if (value.trim().length < 2) {
        _nameError = 'Name must be at least 2 characters';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateMobile(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _mobileError = 'Mobile number is required';
      } else if (value.trim().length != 10) {
        _mobileError = 'Mobile number must be 10 digits';
      } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
        _mobileError = 'Enter valid Indian mobile number';
      } else {
        _mobileError = null;
      }
    });
  }

  void _validateEmployeeId(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _employeeIdError = 'Employee ID is required';
      } else if (value.trim().length < 3) {
        _employeeIdError = 'Employee ID must be at least 3 characters';
      } else {
        _employeeIdError = null;
      }
    });
  }

  void _validatePieceRate(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _pieceRateError = 'Piece rate is required';
      } else {
        final rate = double.tryParse(value.trim());
        if (rate == null) {
          _pieceRateError = 'Enter valid amount';
        } else if (rate <= 0) {
          _pieceRateError = 'Rate must be greater than 0';
        } else if (rate > 1000) {
          _pieceRateError = 'Rate seems too high';
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _joiningDate) {
      setState(() {
        _joiningDate = picked;
        _joiningDateError = null;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ?? DateTime.now().subtract(Duration(days: 18 * 365)),
      firstDate: DateTime.now().subtract(Duration(days: 70 * 365)),
      lastDate: DateTime.now().subtract(Duration(days: 18 * 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _saveDraft() {
    setState(() {
      _isDraftSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Draft saved successfully'),
        backgroundColor: AppTheme.successLight,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveKarigar() async {
    // Validate required fields
    _validateName(_nameController.text);
    _validateMobile(_mobileController.text);
    _validateEmployeeId(_employeeIdController.text);
    _validatePieceRate(_pieceRateController.text);

    if (_joiningDate == null) {
      setState(() {
        _joiningDateError = 'Please select joining date';
      });
    } else {
      setState(() {
        _joiningDateError = null;
      });
    }

    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Prepare karigar data
      final karigarData = {
        'full_name': _nameController.text.trim(),
        'phone': _mobileController.text.trim(),
        'email': _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        'employee_id': _employeeIdController.text.trim(),
        'salary_per_piece': double.parse(_pieceRateController.text.trim()),
        'base_salary': _baseSalaryController.text.trim().isNotEmpty
            ? double.parse(_baseSalaryController.text.trim())
            : null,
        'skill_level': _selectedSkillLevel,
        'specialization': _selectedSpecializations.isNotEmpty
            ? _selectedSpecializations
            : null,
        'joining_date': _joiningDate!.toIso8601String().split('T')[0],
        'date_of_birth': _dateOfBirth?.toIso8601String().split('T')[0],
        'address': _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        'emergency_contact': _emergencyContactController.text.trim().isNotEmpty
            ? _emergencyContactController.text.trim()
            : null,
        'photo_url': _selectedImage
            ?.path, // This would need to be uploaded to Supabase storage
        'is_active': true,
      };

      // Add bank details if provided
      if (_accountNumberController.text.trim().isNotEmpty ||
          _ifscController.text.trim().isNotEmpty ||
          _bankNameController.text.trim().isNotEmpty ||
          _branchController.text.trim().isNotEmpty) {
        karigarData['bank_details'] = {
          'account_number': _accountNumberController.text.trim(),
          'ifsc': _ifscController.text.trim(),
          'bank_name': _bankNameController.text.trim(),
          'branch': _branchController.text.trim(),
        };
      }

      Map<String, dynamic> result;

      if (_isEditing) {
        result = await _karigarService.updateKarigar(
          widget.karigarData!['id'],
          karigarData,
        );
      } else {
        result = await _karigarService.createKarigar(karigarData);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Karigar updated successfully'
              : 'Karigar added successfully'),
          backgroundColor: AppTheme.successLight,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back with result
      Navigator.pop(context, result);
    } catch (error) {
      setState(() {
        _error = error.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save karigar: ${error.toString()}'),
          backgroundColor: AppTheme.errorLight,
          duration: Duration(seconds: 3),
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
      appBar: AppBar(
        title: Text(_screenTitle),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 24,
          ),
        ),
        actions: [
          if (!_isDraftSaved)
            TextButton(
              onPressed: _saveDraft,
              child: Text(
                'Save Draft',
                style: TextStyle(
                  color: AppTheme.lightTheme.appBarTheme.foregroundColor,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                color: AppTheme.errorLight,
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  children: [
                    SizedBox(height: 1.h),

                    // Profile Photo Section
                    ProfilePhotoSection(
                      selectedImage: _selectedImage,
                      onImageSelected: (image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                    ),

                    // Personal Details Section
                    PersonalDetailsSection(
                      nameController: _nameController,
                      mobileController: _mobileController,
                      aadhaarController: _employeeIdController,
                      nameError: _nameError,
                      mobileError: _mobileError,
                      aadhaarError: _employeeIdError,
                      onNameChanged: _validateName,
                      onMobileChanged: _validateMobile,
                      onAadhaarChanged: _validateEmployeeId,
                    ),

                    // Work Details Section
                    WorkDetailsSection(
                      pieceRateController: _pieceRateController,
                      selectedMachine: _selectedMachine,
                      joiningDate: _joiningDate,
                      pieceRateError: _pieceRateError,
                      joiningDateError: _joiningDateError,
                      onPieceRateChanged: _validatePieceRate,
                      onMachineChanged: (value) {
                        setState(() {
                          _selectedMachine = value;
                        });
                      },
                      onJoiningDateChanged: (date) {
                        setState(() {
                          _joiningDate = date;
                        });
                      },
                      onDateTap: _selectJoiningDate,
                    ),

                    // Address Section
                    AddressSection(
                      addressController: _addressController,
                      pincodeController: _emergencyContactController,
                      onAddressChanged: (value) {
                        // Address validation if needed
                      },
                      onPincodeChanged: (value) {
                        // Emergency contact validation if needed
                      },
                    ),

                    // Bank Details Section
                    BankDetailsSection(
                      accountNumberController: _accountNumberController,
                      ifscController: _ifscController,
                      bankNameController: _bankNameController,
                      branchController: _branchController,
                      onAccountNumberChanged: (value) {
                        // Account number validation if needed
                      },
                      onIfscChanged: (value) {
                        // IFSC validation if needed
                      },
                      onBankNameChanged: (value) {
                        // Bank name validation if needed
                      },
                      onBranchChanged: (value) {
                        // Branch validation if needed
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isFormValid && !_isLoading ? _saveKarigar : null,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      _isEditing ? 'Update Karigar' : 'Save Karigar',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}