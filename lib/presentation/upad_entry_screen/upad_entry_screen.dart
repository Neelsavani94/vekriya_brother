import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/karigar_service.dart';
import '../../services/upad_service.dart';
import './widgets/amount_input_widget.dart';
import './widgets/karigar_selection_widget.dart';
import './widgets/payment_mode_widget.dart';
import './widgets/photo_proof_widget.dart';

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
  String _selectedPaymentType = 'advance';
  String _selectedStatus = 'paid';
  DateTime _selectedDate = DateTime.now();
  String? _proofDocumentPath;
  bool _isLoading = false;
  bool _isDraftSaved = false;
  String? _error;

  // Data
  List<Map<String, dynamic>> _availableKarigars = [];
  Map<String, dynamic>? _karigarBalance;

  // Validation errors
  String? _amountError;
  String? _reasonError;
  String? _karigarError;

  final List<String> _paymentTypes = [
    'advance',
    'full_payment',
    'bonus',
    'penalty'
  ];
  final List<String> _paymentStatuses = [
    'pending',
    'paid',
    'partial',
    'cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
    _loadUpadData();
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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load available karigars
      final karigars = await _karigarService.getAvailableKarigars();

      setState(() {
        _availableKarigars = karigars;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to load data: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  void _loadUpadData() {
    if (widget.upadData != null) {
      final data = widget.upadData!;
      _amountController.text = data['amount']?.toString() ?? '';
      _reasonController.text = data['reason'] ?? '';
      _notesController.text = data['notes'] ?? '';
      _selectedKarigarId = data['karigar_id'];
      _selectedPaymentType = data['payment_type'] ?? 'advance';
      _selectedStatus = data['status'] ?? 'paid';
      _proofDocumentPath = data['proof_document_url'];

      if (data['payment_date'] != null) {
        _selectedDate = DateTime.parse(data['payment_date']);
      }
    }
  }

  bool get _isEditing => widget.upadData != null;

  String get _screenTitle => _isEditing ? 'Edit Upad Entry' : 'Add Upad Entry';

  bool get _isFormValid {
    return _selectedKarigarId != null &&
        _amountController.text.trim().isNotEmpty &&
        _reasonController.text.trim().isNotEmpty &&
        _amountError == null &&
        _reasonError == null &&
        _karigarError == null;
  }

  void _validateAmount(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _amountError = 'Amount is required';
      } else {
        final amount = double.tryParse(value.trim());
        if (amount == null) {
          _amountError = 'Enter valid amount';
        } else if (amount <= 0) {
          _amountError = 'Amount must be greater than 0';
        } else if (amount > 100000) {
          _amountError = 'Amount seems too high';
        } else {
          _amountError = null;
        }
      }
    });
  }

  void _validateReason(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _reasonError = 'Reason is required';
      } else if (value.trim().length < 3) {
        _reasonError = 'Reason must be at least 3 characters';
      } else {
        _reasonError = null;
      }
    });
  }

  Future<void> _loadKarigarBalance() async {
    if (_selectedKarigarId == null) return;

    try {
      final balance =
          await _upadService.getKarigarPaymentSummary(_selectedKarigarId!);
      setState(() {
        _karigarBalance = balance;
      });
    } catch (error) {
      // Handle error silently or show a small message
      print('Failed to load karigar balance: $error');
    }
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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

  Future<void> _saveUpadEntry() async {
    // Validate required fields
    _validateAmount(_amountController.text);
    _validateReason(_reasonController.text);

    if (_selectedKarigarId == null) {
      setState(() {
        _karigarError = 'Please select a karigar';
      });
    } else {
      setState(() {
        _karigarError = null;
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
      // Prepare upad entry data
      final upadData = {
        'karigar_id': _selectedKarigarId!,
        'amount': double.parse(_amountController.text.trim()),
        'payment_date': _selectedDate.toIso8601String().split('T')[0],
        'payment_type': _selectedPaymentType,
        'status': _selectedStatus,
        'reason': _reasonController.text.trim(),
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        'proof_document_url': _proofDocumentPath,
      };

      Map<String, dynamic> result;

      if (_isEditing) {
        result = await _upadService.updateUpadPayment(
          widget.upadData!['id'],
          upadData,
        );
      } else {
        result = await _upadService.createUpadPayment(upadData);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Upad entry updated successfully'
              : 'Upad entry added successfully'),
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
          content: Text('Failed to save upad entry: ${error.toString()}'),
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
      body: _isLoading && _availableKarigars.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            )
          : Form(
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

                          // Date Selection
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.h),
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppTheme.getSoftShadow(),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Date',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                GestureDetector(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppTheme.dividerLight),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'calendar_today',
                                          size: 24,
                                          color: AppTheme
                                              .lightTheme.colorScheme.primary,
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Karigar Selection
                          KarigarSelectionWidget(
                            karigars: _availableKarigars,
                            selectedKarigarId: _selectedKarigarId,
                            error: _karigarError,
                            onKarigarSelected: (karigarId) {
                              setState(() {
                                _selectedKarigarId = karigarId;
                                _karigarError = null;
                              });
                              _loadKarigarBalance();
                            },
                            karigarBalance: _karigarBalance,
                          ),

                          // Payment Mode
                          PaymentModeWidget(
                            selectedPaymentMode: _selectedPaymentType,
                            onPaymentModeChanged: (paymentType) {
                              setState(() {
                                _selectedPaymentType = paymentType;
                              });
                            },
                            upiController: TextEditingController(),
                            chequeController: TextEditingController(),
                          ),

                          // Amount Input
                          AmountInputWidget(
                            amountController: _amountController,
                            onAmountChanged: _validateAmount,
                            errorText: _amountError,
                          ),

                          // Photo Proof
                          PhotoProofWidget(
                            selectedImages: [],
                            onImagesChanged: (images) {
                              setState(() {
                                _proofDocumentPath = images.isNotEmpty ? images.first.path : null;
                              });
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
              onPressed: _isFormValid && !_isLoading ? _saveUpadEntry : null,
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
                      _isEditing ? 'Update Upad Entry' : 'Save Upad Entry',
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