import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Clean activity item widget for recent activity list
class ActivityItemWidget extends StatelessWidget {
  final String title;
  final String description;
  final String timestamp;
  final String iconName;
  final Color statusColor;

  const ActivityItemWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.iconName,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dividerLight),
      ),
      child: Row(
        children: [
          // Icon
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
          SizedBox(width: 3.w),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.3.h),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Timestamp
          Text(
            timestamp,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppTheme.textLabelLight,
            ),
          ),
        ],
      ),
    );
  }
}
