import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class KarigarSelectionWidget extends StatelessWidget {
  final String? selectedKarigarId;
  final Function(String) onKarigarSelected;
  final List<Map<String, dynamic>> karigars;
  final String? error;
  final Map<String, dynamic>? karigarBalance;

  const KarigarSelectionWidget({
    Key? key,
    required this.selectedKarigarId,
    required this.onKarigarSelected,
    required this.karigars,
    this.error,
    this.karigarBalance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.getSoftShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Karigar',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          DropdownButtonFormField<String>(
            value: selectedKarigarId,
            decoration: InputDecoration(
              hintText: 'Choose karigar',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.dividerLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.dividerLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              errorText: error,
            ),
            items: karigars.map((karigar) {
              return DropdownMenuItem<String>(
                value: karigar['id'].toString(),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 5.w,
                      backgroundColor:
                          AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            karigar['full_name'] ??
                                karigar['name'] ??
                                'Unknown',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ID: ${karigar['employee_id'] ?? karigar['id']}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onKarigarSelected(value);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a karigar';
              }
              return null;
            },
          ),
          if (selectedKarigarId != null && karigarBalance != null) ...[
            SizedBox(height: 2.h),
            _buildKarigarBalance(),
          ],
        ],
      ),
    );
  }

  Widget _buildKarigarBalance() {
    if (karigarBalance == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Total Paid',
                '₹${karigarBalance!['total_paid']?.toStringAsFixed(0) ?? '0'}',
                AppTheme.lightTheme.colorScheme.secondary,
              ),
              _buildSummaryItem(
                'Total Advance',
                '₹${karigarBalance!['total_advance']?.toStringAsFixed(0) ?? '0'}',
                AppTheme.lightTheme.colorScheme.primary,
              ),
              _buildSummaryItem(
                'Pending',
                '₹${karigarBalance!['total_pending']?.toStringAsFixed(0) ?? '0'}',
                AppTheme.lightTheme.colorScheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
