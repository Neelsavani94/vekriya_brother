import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/daily_work_service.dart';
import '../../services/karigar_service.dart';
import './widgets/date_picker_widget.dart';
import './widgets/earnings_calculation_widget.dart';
import './widgets/karigar_selection_widget.dart';
import './widgets/notes_input_widget.dart';
import './widgets/pieces_input_widget.dart';
import './widgets/recent_entries_widget.dart';

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
  late TextEditingController _hoursController;
  late TextEditingController _rateController;
  late TextEditingController _notesController;

  // Form state
  String? _selectedKarigarId;
  String? _selectedMachineId;
  String _selectedWorkType = 'shirt';
  String _selectedStatus = 'completed';
  DateTime _selectedDate = DateTime.now();
  int? _qualityRating;
  double _totalEarnings = 0.0;
  bool _isLoading = false;
  bool _isDraftSaved = false;
  String? _error;

  // Data
  List<Map<String, dynamic>> _availableKarigars = [];
  List<Map<String, dynamic>> _availableMachines = [];
  List<Map<String, dynamic>> _recentEntries = [];

  // Validation errors
  String? _piecesError;
  String? _hoursError;
  String? _rateError;
  String? _karigarError;
  String? _machineError;

  final List<String> _workTypes = [
    'shirt',
    'pant',
    'dress',
    'jacket',
    'custom'
  ];
  final List<String> _workStatuses = [
    'pending',
    'in_progress',
    'completed',
    'quality_check',
    'delivered'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
    _loadWorkEntryData();
  }

  @override
  void dispose() {
    _piecesController.dispose();
    _hoursController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _piecesController = TextEditingController();
    _hoursController = TextEditingController();
    _rateController = TextEditingController();
    _notesController = TextEditingController();

    // Add listeners for automatic calculation
    _piecesController.addListener(_calculateEarnings);
    _rateController.addListener(_calculateEarnings);
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load available karigars and machines
      final results = await Future.wait([
        _karigarService.getAvailableKarigars(),
        _dailyWorkService.getAvailableMachines(),
        _dailyWorkService.getRecentWorkEntries(limit: 5),
      ]);

      setState(() {
        _availableKarigars = results[0];
        _availableMachines = results[1];
        _recentEntries = results[2];
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to load data: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  void _loadWorkEntryData() {
    if (widget.workEntryData != null) {
      final data = widget.workEntryData!;
      _piecesController.text = data['pieces_completed']?.toString() ?? '';
      _hoursController.text = data['hours_worked']?.toString() ?? '';
      _rateController.text = data['rate_per_piece']?.toString() ?? '';
      _notesController.text = data['notes'] ?? '';
      _selectedKarigarId = data['karigar_id'];
      _selectedMachineId = data['machine_id'];
      _selectedWorkType = data['work_type'] ?? 'shirt';
      _selectedStatus = data['status'] ?? 'completed';
      _qualityRating = data['quality_rating'];

      if (data['work_date'] != null) {
        _selectedDate = DateTime.parse(data['work_date']);
      }

      _calculateEarnings();
    }
  }

  bool get _isEditing => widget.workEntryData != null;

  String get _screenTitle => _isEditing ? 'Edit Daily Work' : 'Add Daily Work';

  void _calculateEarnings() {
    final pieces = int.tryParse(_piecesController.text) ?? 0;
    final rate = double.tryParse(_rateController.text) ?? 0.0;

    setState(() {
      _totalEarnings = pieces * rate;
    });
  }

  bool get _isFormValid {
    return _selectedKarigarId != null &&
        _selectedMachineId != null &&
        _piecesController.text.trim().isNotEmpty &&
        _rateController.text.trim().isNotEmpty &&
        _piecesError == null &&
        _rateError == null &&
        _karigarError == null &&
        _machineError == null;
  }

  void _validatePieces(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _piecesError = 'Pieces completed is required';
      } else {
        final pieces = int.tryParse(value.trim());
        if (pieces == null) {
          _piecesError = 'Enter valid number of pieces';
        } else if (pieces <= 0) {
          _piecesError = 'Pieces must be greater than 0';
        } else if (pieces > 1000) {
          _piecesError = 'Pieces seem too high';
        } else {
          _piecesError = null;
        }
      }
    });
  }

  void _validateHours(String value) {
    setState(() {
      if (value.trim().isNotEmpty) {
        final hours = double.tryParse(value.trim());
        if (hours == null) {
          _hoursError = 'Enter valid hours';
        } else if (hours <= 0) {
          _hoursError = 'Hours must be greater than 0';
        } else if (hours > 24) {
          _hoursError = 'Hours cannot exceed 24';
        } else {
          _hoursError = null;
        }
      } else {
        _hoursError = null;
      }
    });
  }

  void _validateRate(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _rateError = 'Rate per piece is required';
      } else {
        final rate = double.tryParse(value.trim());
        if (rate == null) {
          _rateError = 'Enter valid rate';
        } else if (rate <= 0) {
          _rateError = 'Rate must be greater than 0';
        } else if (rate > 1000) {
          _rateError = 'Rate seems too high';
        } else {
          _rateError = null;
        }
      }
    });
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

  Future<void> _saveWorkEntry() async {
    // Validate required fields
    _validatePieces(_piecesController.text);
    _validateRate(_rateController.text);
    _validateHours(_hoursController.text);

    if (_selectedKarigarId == null) {
      setState(() {
        _karigarError = 'Please select a karigar';
      });
    } else {
      setState(() {
        _karigarError = null;
      });
    }

    if (_selectedMachineId == null) {
      setState(() {
        _machineError = 'Please select a machine';
      });
    } else {
      setState(() {
        _machineError = null;
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
      // Prepare work entry data
      final workEntryData = {
        'karigar_id': _selectedKarigarId!,
        'machine_id': _selectedMachineId!,
        'work_date': _selectedDate.toIso8601String().split('T')[0],
        'work_type': _selectedWorkType,
        'pieces_completed': int.parse(_piecesController.text.trim()),
        'hours_worked': _hoursController.text.trim().isNotEmpty
            ? double.parse(_hoursController.text.trim())
            : null,
        'rate_per_piece': double.parse(_rateController.text.trim()),
        'status': _selectedStatus,
        'quality_rating': _qualityRating,
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      };

      Map<String, dynamic> result;

      if (_isEditing) {
        result = await _dailyWorkService.updateDailyWorkEntry(
          widget.workEntryData!['id'],
          workEntryData,
        );
      } else {
        result = await _dailyWorkService.createDailyWorkEntry(workEntryData);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Work entry updated successfully'
              : 'Work entry added successfully'),
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
          content: Text('Failed to save work entry: ${error.toString()}'),
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

                          // Date Picker
                          DatePickerWidget(
                            selectedDate: _selectedDate,
                            onDateChanged: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                          ),

                          // Karigar Selection
                          KarigarSelectionWidget(
                            selectedKarigar: _selectedKarigarId != null
                                ? _availableKarigars.firstWhere(
                                    (k) => k['id'] == _selectedKarigarId,
                                    orElse: () => {},
                                  )
                                : null,
                            onKarigarSelected: (karigar) {
                              setState(() {
                                _selectedKarigarId = karigar['id'];
                                _karigarError = null;

                                // Auto-fill rate from karigar data
                                if (karigar['salary_per_piece'] != null) {
                                  _rateController.text =
                                      karigar['salary_per_piece'].toString();
                                  _calculateEarnings();
                                }
                              });
                            },
                            karigarList: _availableKarigars,
                          ),

                          // Pieces Input
                          PiecesInputWidget(
                            controller: _piecesController,
                            onChanged: _validatePieces,
                          ),

                          // Earnings Calculation
                          EarningsCalculationWidget(
                            pieces: int.tryParse(_piecesController.text) ?? 0,
                            pieceRate: double.tryParse(_rateController.text) ?? 0.0,
                            karigarName: _selectedKarigarId != null
                                ? (_availableKarigars.firstWhere(
                                    (k) => k['id'] == _selectedKarigarId,
                                    orElse: () => {'name': 'Unknown'},
                                  )['name'] as String)
                                : 'Not Selected',
                          ),

                          // Notes Input
                          NotesInputWidget(
                            controller: _notesController,
                            onChanged: (value) {
                              // Notes validation if needed
                            },
                          ),

                          // Recent Entries
                          if (_recentEntries.isNotEmpty)
                            RecentEntriesWidget(
                              recentEntries: _recentEntries,
                              onEditEntry: (entry) {
                                // Handle entry tap - could prefill form
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Entry details: ${entry['work_type']} - ${entry['pieces_completed']} pieces'),
                                  ),
                                );
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
              onPressed: _isFormValid && !_isLoading ? _saveWorkEntry : null,
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
                      _isEditing ? 'Update Work Entry' : 'Save Work Entry',
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