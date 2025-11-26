import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OverviewTabWidget extends StatelessWidget {
  final Map<String, dynamic> karigarData;

  const OverviewTabWidget({
    Key? key,
    required this.karigarData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Personal Information',
            icon: 'person',
            children: [
              _buildDetailRow(
                  'Full Name', (karigarData['name'] as String?) ?? 'N/A'),
              _buildDetailRow(
                  'Mobile Number', (karigarData['mobile'] as String?) ?? 'N/A'),
              _buildDetailRow('Aadhaar Number',
                  (karigarData['aadhaarNumber'] as String?) ?? 'N/A'),
              _buildDetailRow('Date of Birth',
                  (karigarData['dateOfBirth'] as String?) ?? 'N/A'),
              _buildDetailRow(
                  'Gender', (karigarData['gender'] as String?) ?? 'N/A'),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSectionCard(
            title: 'Work Details',
            icon: 'work',
            children: [
              _buildDetailRow('Machine Number',
                  'Machine ${(karigarData['machineNumber'] as String?) ?? 'N/A'}'),
              _buildDetailRow('Piece Rate',
                  '₹${(karigarData['pieceRate'] as double?)?.toStringAsFixed(2) ?? '0.00'} per piece'),
              _buildDetailRow('Joining Date',
                  (karigarData['joiningDate'] as String?) ?? 'N/A'),
              _buildDetailRow('Employment Type',
                  (karigarData['employmentType'] as String?) ?? 'Full Time'),
              _buildDetailRow(
                  'Shift', (karigarData['shift'] as String?) ?? 'Day Shift'),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSectionCard(
            title: 'Address Information',
            icon: 'location_on',
            children: [
              _buildDetailRow('Street Address',
                  (karigarData['address']?['street'] as String?) ?? 'N/A'),
              _buildDetailRow('City',
                  (karigarData['address']?['city'] as String?) ?? 'N/A'),
              _buildDetailRow('State',
                  (karigarData['address']?['state'] as String?) ?? 'N/A'),
              _buildDetailRow('PIN Code',
                  (karigarData['address']?['pinCode'] as String?) ?? 'N/A'),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSectionCard(
            title: 'Bank Details',
            icon: 'account_balance',
            children: [
              _buildDetailRow(
                  'Account Holder Name',
                  (karigarData['bankDetails']?['accountHolderName']
                          as String?) ??
                      'N/A'),
              _buildDetailRow(
                  'Account Number',
                  (karigarData['bankDetails']?['accountNumber'] as String?) ??
                      'N/A'),
              _buildDetailRow(
                  'IFSC Code',
                  (karigarData['bankDetails']?['ifscCode'] as String?) ??
                      'N/A'),
              _buildDetailRow(
                  'Bank Name',
                  (karigarData['bankDetails']?['bankName'] as String?) ??
                      'N/A'),
              _buildDetailRow('Branch',
                  (karigarData['bankDetails']?['branch'] as String?) ?? 'N/A'),
            ],
          ),
          SizedBox(height: 3.h),
          _buildSectionCard(
            title: 'Emergency Contact',
            icon: 'emergency',
            children: [
              _buildDetailRow(
                  'Contact Name',
                  (karigarData['emergencyContact']?['name'] as String?) ??
                      'N/A'),
              _buildDetailRow(
                  'Relationship',
                  (karigarData['emergencyContact']?['relationship']
                          as String?) ??
                      'N/A'),
              _buildDetailRow(
                  'Phone Number',
                  (karigarData['emergencyContact']?['phone'] as String?) ??
                      'N/A'),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
