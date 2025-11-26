import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Clean metric card widget for displaying statistics
class MetricCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color statusColor;
  final String iconName;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MetricCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.statusColor,
    required this.iconName,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomIconWidget(
                    iconName: iconName,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppTheme.textLabelLight,
                  size: 14,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryLight,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.textLabelLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
