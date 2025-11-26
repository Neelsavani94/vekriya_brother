import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> karigarData;
  final VoidCallback onEditPressed;
  final VoidCallback onCallPressed;
  final VoidCallback onWhatsAppPressed;

  const ProfileHeaderWidget({
    Key? key,
    required this.karigarData,
    required this.onEditPressed,
    required this.onCallPressed,
    required this.onWhatsAppPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      (karigarData['name'] as String?) ?? 'Karigar Profile',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: 'edit',
                        onTap: onEditPressed,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      SizedBox(width: 2.w),
                      _buildActionButton(
                        icon: 'call',
                        onTap: onCallPressed,
                        color: Colors.green,
                      ),
                      SizedBox(width: 2.w),
                      _buildActionButton(
                        icon: 'chat',
                        onTap: onWhatsAppPressed,
                        color: Color(0xFF25D366),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Profile Card
            Container(
              margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  // Profile Photo
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: karigarData['profilePhoto'] != null
                          ? CustomImageWidget(
                              imageUrl: karigarData['profilePhoto'] as String,
                              width: 20.w,
                              height: 20.w,
                              fit: BoxFit.cover,
                              semanticLabel:
                                  "Profile photo of ${karigarData['name'] ?? 'karigar'}",
                            )
                          : Container(
                              color: AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              child: CustomIconWidget(
                                iconName: 'person',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 8.w,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 4.w),

                  // Profile Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (karigarData['name'] as String?) ?? 'Unknown',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        _buildInfoRow(
                          icon: 'phone',
                          text: (karigarData['mobile'] as String?) ?? 'N/A',
                        ),
                        SizedBox(height: 0.5.h),
                        _buildInfoRow(
                          icon: 'precision_manufacturing',
                          text:
                              'Machine ${(karigarData['machineNumber'] as String?) ?? 'N/A'}',
                        ),
                        SizedBox(height: 0.5.h),
                        _buildInfoRow(
                          icon: 'currency_rupee',
                          text:
                              '₹${(karigarData['pieceRate'] as double?)?.toStringAsFixed(2) ?? '0.00'}/piece',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: color,
          size: 5.w,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String icon,
    required String text,
  }) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
