import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Clean karigar card widget for list display
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = karigar['status'] == 'active';
    final String earnings =
        (karigar['currentMonthEarnings'] as double).toStringAsFixed(0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
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
                            color: isActive
                                ? AppTheme.successLight
                                : AppTheme.textLabelLight,
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
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

            // More Menu
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppTheme.textLabelLight,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                _buildMenuItem('call', Icons.call_rounded, 'Call', AppTheme.primaryLight),
                _buildMenuItem('whatsapp', Icons.chat_rounded, 'WhatsApp', AppTheme.successLight),
                _buildMenuItem('edit', Icons.edit_rounded, 'Edit', AppTheme.warningLight),
                _buildMenuItem('delete', Icons.delete_rounded, 'Delete', AppTheme.errorLight),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
