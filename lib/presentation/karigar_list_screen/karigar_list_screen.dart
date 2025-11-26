import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/daily_work_service.dart';
import '../../services/karigar_service.dart';
import '../../services/upad_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/karigar_card_widget.dart';
import './widgets/search_filter_bar_widget.dart';

class KarigarListScreen extends StatefulWidget {
  const KarigarListScreen({Key? key}) : super(key: key);

  @override
  State<KarigarListScreen> createState() => _KarigarListScreenState();
}

class _KarigarListScreenState extends State<KarigarListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Services
  final KarigarService _karigarService = KarigarService();
  final DailyWorkService _dailyWorkService = DailyWorkService();
  final UpadService _upadService = UpadService();

  List<Map<String, dynamic>> _allKarigars = [];
  List<Map<String, dynamic>> _filteredKarigars = [];
  Map<String, dynamic> _activeFilters = {
    'status': 'All',
    'machine': 'All',
    'sortBy': 'Name A-Z',
    'minEarnings': 0.0,
    'maxEarnings': 50000.0,
  };

  bool _isLoading = true;
  String _searchQuery = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadKarigarData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadKarigarData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch karigars from Supabase
      final karigars = await _karigarService.getKarigars();

      // Process the data to match the expected format
      final processedKarigars = karigars.map((karigar) {
        return {
          'id': karigar['id'],
          'name': karigar['full_name'] ?? '',
          'mobile': karigar['phone'] ?? '',
          'profilePhoto': karigar['photo_url'],
          'semanticLabel':
              'Profile photo of ${karigar['full_name'] ?? 'karigar'}',
          'assignedMachine':
              '1', // Will be enhanced with machine assignment data
          'pieceRate': (karigar['salary_per_piece'] as num?)?.toDouble() ?? 0.0,
          'currentMonthEarnings':
              (karigar['base_salary'] as num?)?.toDouble() ?? 0.0,
          'status': karigar['is_active'] == true ? 'active' : 'inactive',
          'aadhaar': '', // Will be populated from documents if needed
          'address': karigar['address'] ?? '',
          'bankDetails': _formatBankDetails(karigar['bank_details']),
          'employee_id': karigar['employee_id'],
          'skill_level': karigar['skill_level'],
          'joining_date': karigar['joining_date'],
        };
      }).toList();

      setState(() {
        _allKarigars = processedKarigars;
        _isLoading = false;
      });

      _applyFiltersAndSearch();
    } catch (error) {
      setState(() {
        _error = 'Failed to load karigars: ${error.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatBankDetails(dynamic bankDetails) {
    if (bankDetails == null) return '';
    if (bankDetails is Map) {
      final bankName = bankDetails['bank_name'] ?? '';
      final accountNumber = bankDetails['account_number'] ?? '';
      return '$bankName - $accountNumber';
    }
    return bankDetails.toString();
  }

  void _applyFiltersAndSearch() {
    List<Map<String, dynamic>> filtered = List.from(_allKarigars);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((karigar) {
        final name = (karigar['name'] as String).toLowerCase();
        final mobile = (karigar['mobile'] as String).toLowerCase();
        final employeeId =
            (karigar['employee_id'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            mobile.contains(query) ||
            employeeId.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_activeFilters['status'] != 'All') {
      final statusFilter = _activeFilters['status'].toString().toLowerCase();
      filtered = filtered
          .where((karigar) =>
              (karigar['status'] as String).toLowerCase() == statusFilter)
          .toList();
    }

    // Apply earnings range filter
    final minEarnings = _activeFilters['minEarnings'] as double;
    final maxEarnings = _activeFilters['maxEarnings'] as double;
    filtered = filtered.where((karigar) {
      final earnings = karigar['currentMonthEarnings'] as double;
      return earnings >= minEarnings && earnings <= maxEarnings;
    }).toList();

    // Apply sorting
    final sortBy = _activeFilters['sortBy'] as String;
    switch (sortBy) {
      case 'Name A-Z':
        filtered.sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String));
        break;
      case 'Name Z-A':
        filtered.sort(
            (a, b) => (b['name'] as String).compareTo(a['name'] as String));
        break;
      case 'Earnings High-Low':
        filtered.sort((a, b) => (b['currentMonthEarnings'] as double)
            .compareTo(a['currentMonthEarnings'] as double));
        break;
      case 'Earnings Low-High':
        filtered.sort((a, b) => (a['currentMonthEarnings'] as double)
            .compareTo(b['currentMonthEarnings'] as double));
        break;
    }

    setState(() {
      _filteredKarigars = filtered;
    });
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_activeFilters['status'] != 'All') count++;
    if (_activeFilters['machine'] != 'All') count++;
    if (_activeFilters['sortBy'] != 'Name A-Z') count++;
    if (_activeFilters['minEarnings'] != 0.0 ||
        _activeFilters['maxEarnings'] != 50000.0) count++;
    return count;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _applyFiltersAndSearch();
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSearch();
  }

  Future<void> _refreshKarigars() async {
    await _loadKarigarData();
  }

  void _navigateToKarigarProfile(Map<String, dynamic> karigar) {
    Navigator.pushNamed(
      context,
      '/karigar-profile-screen',
      arguments: karigar,
    );
  }

  void _navigateToAddKarigar() {
    Navigator.pushNamed(context, '/add-edit-karigar-screen').then((result) {
      if (result != null) {
        // Refresh the list when returning from add screen
        _loadKarigarData();
      }
    });
  }

  void _navigateToEditKarigar(Map<String, dynamic> karigar) {
    Navigator.pushNamed(
      context,
      '/add-edit-karigar-screen',
      arguments: {
        'id': karigar['id'],
        'name': karigar['name'],
        'mobile': karigar['mobile'],
        'employee_id': karigar['employee_id'],
        'pieceRate': karigar['pieceRate'],
        'joiningDate': karigar['joining_date'],
        'address': karigar['address'],
        'skill_level': karigar['skill_level'],
      },
    ).then((result) {
      if (result != null) {
        // Refresh the list when returning from edit screen
        _loadKarigarData();
      }
    });
  }

  Future<void> _showDeleteConfirmation(Map<String, dynamic> karigar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Karigar'),
        content: Text(
            'Are you sure you want to delete ${karigar['name']}? This will deactivate the karigar account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _karigarService.deleteKarigar(karigar['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${karigar['name']} deleted successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
        _loadKarigarData(); // Refresh the list
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete karigar: ${error.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Karigars'),
        leading: IconButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/main-dashboard'),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Karigars'),
            Tab(text: 'Daily Work'),
            Tab(text: 'Upad'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Karigars Tab
          Column(
            children: [
              // Search and Filter Bar
              SearchFilterBarWidget(
                searchController: _searchController,
                onSearchChanged: _onSearchChanged,
                onFilterTap: _showFilterBottomSheet,
                activeFiltersCount: _getActiveFiltersCount(),
              ),

              // Karigar List
              Expanded(
                child: _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60,
                              color: AppTheme.lightTheme.colorScheme.error,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Error',
                              style:
                                  AppTheme.lightTheme.textTheme.headlineSmall,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            SizedBox(height: 3.h),
                            ElevatedButton(
                              onPressed: _loadKarigarData,
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          )
                        : _filteredKarigars.isEmpty
                            ? _searchQuery.isNotEmpty
                                ? EmptyStateWidget(
                                    title: 'No Results Found',
                                    subtitle:
                                        'No karigars match your search criteria. Try adjusting your search or filters.',
                                    buttonText: 'Clear Search',
                                    isSearchResult: true,
                                    onButtonPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : EmptyStateWidget(
                                    title: 'No Karigars Yet',
                                    subtitle:
                                        'Add your first karigar to start managing your textile workflow and tracking daily work.',
                                    buttonText: 'Add First Karigar',
                                    onButtonPressed: _navigateToAddKarigar,
                                  )
                            : RefreshIndicator(
                                onRefresh: _refreshKarigars,
                                color: AppTheme.lightTheme.colorScheme.primary,
                                child: ListView.builder(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  itemCount: _filteredKarigars.length,
                                  itemBuilder: (context, index) {
                                    final karigar = _filteredKarigars[index];
                                    return KarigarCardWidget(
                                      karigar: karigar,
                                      onTap: () =>
                                          _navigateToKarigarProfile(karigar),
                                      onCall: () {
                                        // Handle call functionality
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Calling ${karigar['name']}...'),
                                          ),
                                        );
                                      },
                                      onWhatsApp: () {
                                        // Handle WhatsApp functionality
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Opening WhatsApp for ${karigar['name']}...'),
                                          ),
                                        );
                                      },
                                      onEdit: () =>
                                          _navigateToEditKarigar(karigar),
                                      onDelete: () =>
                                          _showDeleteConfirmation(karigar),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),

          // Daily Work Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'work',
                  size: 60,
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.6),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Daily Work Management',
                  style: AppTheme.lightTheme.textTheme.headlineSmall,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Track daily work entries for all karigars',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/daily-work-entry-screen'),
                  child: Text('Add Daily Work'),
                ),
              ],
            ),
          ),

          // Upad Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'account_balance_wallet',
                  size: 60,
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.6),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Upad Management',
                  style: AppTheme.lightTheme.textTheme.headlineSmall,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Manage advance payments for karigars',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/upad-entry-screen'),
                  child: Text('Add Upad Entry'),
                ),
              ],
            ),
          ),

          // Reports Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'assessment',
                  size: 60,
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.6),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Reports & Analytics',
                  style: AppTheme.lightTheme.textTheme.headlineSmall,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Generate detailed reports and summaries',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reports feature coming soon!'),
                      ),
                    );
                  },
                  child: Text('View Reports'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddKarigar,
              icon: CustomIconWidget(
                iconName: 'add',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onSecondary,
              ),
              label: Text(
                'Add Karigar',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : null,
    );
  }
}
