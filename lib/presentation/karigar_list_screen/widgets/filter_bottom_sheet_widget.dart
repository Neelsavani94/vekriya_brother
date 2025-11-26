import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Clean filter bottom sheet widget
class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const FilterBottomSheetWidget({
    Key? key,
    required this.currentFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() => _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  final List<String> _statusOptions = ['All', 'Active', 'Inactive'];
  final List<String> _sortOptions = [
    'Name A-Z',
    'Name Z-A',
    'Earnings High-Low',
    'Earnings Low-High'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  void _resetFilters() {
    setState(() {
      _filters = {
        'status': 'All',
        'machine': 'All',
        'sortBy': 'Name A-Z',
        'minEarnings': 0.0,
        'maxEarnings': 50000.0,
      };
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_filters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.h,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.5.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.dividerLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(5.w),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: AppTheme.textSecondaryLight),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filter
                  _buildFilterSection(
                    title: 'Status',
                    child: Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: _statusOptions.map((status) {
                        final isSelected = _filters['status'] == status;
                        return _buildChip(
                          label: status,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _filters['status'] = status;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Sort By Filter
                  _buildFilterSection(
                    title: 'Sort By',
                    child: Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: _sortOptions.map((option) {
                        final isSelected = _filters['sortBy'] == option;
                        return _buildChip(
                          label: option,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _filters['sortBy'] = option;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
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
                  onPressed: _applyFilters,
                  child: Text('Apply Filters'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryLight,
          ),
        ),
        SizedBox(height: 1.5.h),
        child,
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
