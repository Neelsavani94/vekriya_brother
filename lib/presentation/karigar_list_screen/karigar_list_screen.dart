import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/karigar_service.dart';

class KarigarListScreen extends StatefulWidget {
  const KarigarListScreen({Key? key}) : super(key: key);

  @override
  State<KarigarListScreen> createState() => _KarigarListScreenState();
}

class _KarigarListScreenState extends State<KarigarListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final KarigarService _karigarService = KarigarService();

  List<Map<String, dynamic>> _allKarigars = [];
  List<Map<String, dynamic>> _filteredKarigars = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _error;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadKarigarData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadKarigarData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final karigars = await _karigarService.getKarigars();

      final processedKarigars = karigars.map((karigar) {
        return {
          'id': karigar['id'],
          'name': karigar['full_name'] ?? '',
          'mobile': karigar['phone'] ?? '',
          'profilePhoto': karigar['photo_url'],
          'pieceRate': (karigar['salary_per_piece'] as num?)?.toDouble() ?? 0.0,
          'currentMonthEarnings': (karigar['base_salary'] as num?)?.toDouble() ?? 0.0,
          'status': karigar['is_active'] == true ? 'active' : 'inactive',
          'employee_id': karigar['employee_id'] ?? '',
          'skill_level': karigar['skill_level'] ?? 'beginner',
          'joining_date': karigar['joining_date'],
        };
      }).toList();

      setState(() {
        _allKarigars = processedKarigars;
        _isLoading = false;
      });

      _applyFilters();
    } catch (error) {
      setState(() {
        _error = 'Failed to load karigars';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allKarigars);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((karigar) {
        final name = (karigar['name'] as String).toLowerCase();
        final mobile = (karigar['mobile'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || mobile.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((karigar) {
        return karigar['status'] == _selectedFilter.toLowerCase();
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

    setState(() {
      _filteredKarigars = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  Future<void> _refreshKarigars() async {
    await _loadKarigarData();
  }

  void _navigateToAddKarigar() {
    Navigator.pushNamed(context, '/add-edit-karigar-screen').then((result) {
      if (result != null) {
        _loadKarigarData();
      }
    });
  }

  void _navigateToKarigarProfile(Map<String, dynamic> karigar) {
    Navigator.pushNamed(
      context,
      '/karigar-profile-screen',
      arguments: karigar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search and Filter
            _buildSearchBar(),
            
            // Filter Chips
            _buildFilterChips(),
            
            // Karigar List
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _error != null
                      ? _buildErrorState()
                      : _filteredKarigars.isEmpty
                          ? _buildEmptyState()
                          : _buildKarigarList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddKarigar,
        backgroundColor: AppTheme.primaryLight,
        icon: Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Karigar',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Row(
        children: [
          Text(
            'Karigars',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_allKarigars.length} Total',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dividerLight),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: AppTheme.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'Search by name or phone...',
            hintStyle: GoogleFonts.poppins(
              color: AppTheme.textLabelLight,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppTheme.textSecondaryLight,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSecondaryLight,
                      size: 20,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Active', 'Inactive'];
    
    return Container(
      height: 6.h,
      padding: EdgeInsets.only(left: 5.w, top: 1.5.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                _applyFilters();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryLight : AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryLight : AppTheme.dividerLight,
                  ),
                ),
                child: Text(
                  filter,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryLight,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppTheme.errorLight,
          ),
          SizedBox(height: 2.h),
          Text(
            'Failed to load karigars',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: _loadKarigarData,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.people_outline_rounded,
                size: 48,
                color: AppTheme.primaryLight,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              _searchQuery.isNotEmpty ? 'No results found' : 'No karigars yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Add your first karigar to get started',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isEmpty) ...[
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: _navigateToAddKarigar,
                icon: Icon(Icons.add_rounded),
                label: Text('Add Karigar'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKarigarList() {
    return RefreshIndicator(
      onRefresh: _refreshKarigars,
      color: AppTheme.primaryLight,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        itemCount: _filteredKarigars.length,
        itemBuilder: (context, index) {
          final karigar = _filteredKarigars[index];
          return _buildKarigarCard(karigar);
        },
      ),
    );
  }

  Widget _buildKarigarCard(Map<String, dynamic> karigar) {
    final bool isActive = karigar['status'] == 'active';
    final earnings = (karigar['currentMonthEarnings'] as double).toStringAsFixed(0);

    return GestureDetector(
      onTap: () => _navigateToKarigarProfile(karigar),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dividerLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Photo
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? AppTheme.successLight : AppTheme.dividerLight,
                  width: 2,
                ),
              ),
              child: karigar['profilePhoto'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CustomImageWidget(
                        imageUrl: karigar['profilePhoto'] as String,
                        width: 14.w,
                        height: 14.w,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        _getInitials(karigar['name'] as String),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: 4.w),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          karigar['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.successLight.withValues(alpha: 0.12)
                              : AppTheme.textLabelLight.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isActive ? AppTheme.successLight : AppTheme.textLabelLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_rounded,
                        size: 14,
                        color: AppTheme.textSecondaryLight,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        karigar['mobile'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '₹${karigar['pieceRate']}/piece',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        'This Month: ',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textLabelLight,
                        ),
                      ),
                      Text(
                        '₹$earnings',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.successLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textLabelLight,
              size: 24,
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
}
