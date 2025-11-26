import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const FilterBottomSheetWidget({
    Key? key,
    required this.currentFilters,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  final List<String> _statusOptions = ['All', 'Active', 'Inactive'];
  final List<String> _machineOptions = [
    'All',
    'Machine 1',
    'Machine 2',
    'Machine 3',
    'Machine 4',
    'Machine 5'
  ];
  final List<String> _sortOptions = [
    'Name A-Z',
    'Name Z-A',
    'Earnings High-Low',
    'Earnings Low-High'
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Karigars',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Filter Options
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filter
                  _buildFilterSection(
                    title: 'Status',
                    options: _statusOptions,
                    selectedValue: _filters['status'] ?? 'All',
                    onChanged: (value) {
                      setState(() {
                        _filters['status'] = value;
                      });
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Machine Filter
                  _buildFilterSection(
                    title: 'Machine Assignment',
                    options: _machineOptions,
                    selectedValue: _filters['machine'] ?? 'All',
                    onChanged: (value) {
                      setState(() {
                        _filters['machine'] = value;
                      });
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Sort By
                  _buildFilterSection(
                    title: 'Sort By',
                    options: _sortOptions,
                    selectedValue: _filters['sortBy'] ?? 'Name A-Z',
                    onChanged: (value) {
                      setState(() {
                        _filters['sortBy'] = value;
                      });
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Earnings Range
                  _buildEarningsRangeFilter(),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFiltersApplied(_filters);
                      Navigator.pop(context);
                    },
                    child: Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged(option);
                }
              },
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              selectedColor: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.2),
              checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
              labelStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEarningsRangeFilter() {
    final double minEarnings = (_filters['minEarnings'] ?? 0.0).toDouble();
    final double maxEarnings = (_filters['maxEarnings'] ?? 50000.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earnings Range',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Text(
              '₹${minEarnings.toInt()}',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            Expanded(
              child: RangeSlider(
                values: RangeValues(minEarnings, maxEarnings),
                min: 0,
                max: 50000,
                divisions: 50,
                labels: RangeLabels(
                  '₹${minEarnings.toInt()}',
                  '₹${maxEarnings.toInt()}',
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _filters['minEarnings'] = values.start;
                    _filters['maxEarnings'] = values.end;
                  });
                },
              ),
            ),
            Text(
              '₹${maxEarnings.toInt()}',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  void _clearAllFilters() {
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
}
