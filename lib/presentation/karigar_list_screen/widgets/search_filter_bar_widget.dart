import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Clean search and filter bar widget
class SearchFilterBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final int activeFiltersCount;

  const SearchFilterBarWidget({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    this.activeFiltersCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.dividerLight),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppTheme.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: 'Search karigars...',
                  hintStyle: GoogleFonts.poppins(
                    color: AppTheme.textLabelLight,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppTheme.textSecondaryLight,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.8.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          
          // Filter Button
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: activeFiltersCount > 0
                    ? AppTheme.primaryLight
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: activeFiltersCount > 0
                      ? AppTheme.primaryLight
                      : AppTheme.dividerLight,
                ),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: activeFiltersCount > 0
                        ? Colors.white
                        : AppTheme.textSecondaryLight,
                    size: 22,
                  ),
                  if (activeFiltersCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          color: AppTheme.warningLight,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$activeFiltersCount',
                          style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
