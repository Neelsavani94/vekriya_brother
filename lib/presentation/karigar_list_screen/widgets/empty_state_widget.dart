import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Clean empty state widget for no data scenarios
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool isSearchResult;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.onButtonPressed,
    this.isSearchResult = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                isSearchResult
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 48,
                color: AppTheme.primaryLight,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onButtonPressed != null) ...[
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: Icon(isSearchResult ? Icons.clear_rounded : Icons.add_rounded),
                label: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
