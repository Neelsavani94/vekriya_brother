import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class KarigarCardWidget extends StatelessWidget {
  final Map<String, dynamic> karigar;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onWhatsApp;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const KarigarCardWidget({
    Key? key,
    required this.karigar,
    this.onTap,
    this.onCall,
    this.onWhatsApp,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isActive = karigar['status'] == 'active';
    final String earnings =
        (karigar['currentMonthEarnings'] as double).toStringAsFixed(0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive 
              ? AppTheme.primaryLight.withValues(alpha: 0.2)
              : AppTheme.dividerLight,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? AppTheme.primaryLight.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Top Row: Profile Photo, Name, and Quick Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Profile Photo with Status Indicator
                    Stack(
                      children: [
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isActive 
                                ? LinearGradient(
                                    colors: [
                                      AppTheme.primaryLight,
                                      AppTheme.primaryLight.withValues(alpha: 0.7),
                                    ],
                                  )
                                : null,
                            border: Border.all(
                              color: isActive
                                  ? AppTheme.primaryLight
                                  : AppTheme.dividerLight,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: CustomImageWidget(
                              imageUrl: karigar['profilePhoto'] as String,
                              width: 18.w,
                              height: 18.w,
                              fit: BoxFit.cover,
                              semanticLabel: karigar['semanticLabel'] as String,
                            ),
                          ),
                        ),
                        // Active Status Indicator
                        if (isActive)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                width: 3.w,
                                height: 3.w,
                                decoration: BoxDecoration(
                                  color: AppTheme.successLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 3.w),

                    // Worker Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  karigar['name'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.5.w, vertical: 0.6.h),
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? LinearGradient(
                                      colors: [
                                        AppTheme.successLight,
                                        AppTheme.successLight.withValues(alpha: 0.7),
                                      ],
                                    )
                                  : null,
                              color: isActive ? null : AppTheme.dividerLight.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  size: 14,
                                  color: isActive ? Colors.white : AppTheme.textSecondaryLight,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isActive ? Colors.white : AppTheme.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Action Menu
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: AppTheme.primaryLight,
                          size: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'call':
                              onCall?.call();
                              break;
                            case 'whatsapp':
                              onWhatsApp?.call();
                              break;
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'call',
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.call_rounded,
                                    size: 20,
                                    color: AppTheme.primaryLight,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Call Worker',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'whatsapp',
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.chat_rounded,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'WhatsApp',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningLight.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 20,
                                    color: AppTheme.warningLight,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Edit Details',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorLight.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.delete_rounded,
                                    size: 20,
                                    color: AppTheme.errorLight,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Delete',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.errorLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Contact Information
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 18,
                            color: AppTheme.primaryLight,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            karigar['mobile'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryLight,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.warningLight.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.currency_rupee_rounded,
                                  size: 14,
                                  color: AppTheme.warningLight,
                                ),
                                Text(
                                  '${karigar['pieceRate']}/pc',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.warningLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 1.5.h),

                // Earnings Display
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.5.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.successLight.withValues(alpha: 0.12),
                        AppTheme.successLight.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.successLight.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 16,
                                color: AppTheme.successLight,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'This Month',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Total Earnings',
                            style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹$earnings',
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.successLight,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
