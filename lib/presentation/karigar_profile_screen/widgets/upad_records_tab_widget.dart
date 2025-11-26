import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UpadRecordsTabWidget extends StatefulWidget {
  final Map<String, dynamic> karigarData;

  const UpadRecordsTabWidget({
    Key? key,
    required this.karigarData,
  }) : super(key: key);

  @override
  State<UpadRecordsTabWidget> createState() => _UpadRecordsTabWidgetState();
}

class _UpadRecordsTabWidgetState extends State<UpadRecordsTabWidget> {
  List<Map<String, dynamic>> upadRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUpadRecords();
  }

  void _loadUpadRecords() {
    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {
        upadRecords = [
          {
            'id': 1,
            'amount': 2000.0,
            'date': '15/11/2025',
            'paymentMode': 'Cash',
            'notes': 'Festival advance for Diwali expenses',
            'proofPhoto':
                'https://images.unsplash.com/photo-1572874865861-4d98c131b693',
            'timestamp': DateTime.now().subtract(Duration(days: 3)),
            'status': 'Approved',
          },
          {
            'id': 2,
            'amount': 1500.0,
            'date': '08/11/2025',
            'paymentMode': 'Bank Transfer',
            'notes': 'Medical emergency for family member',
            'proofPhoto':
                'https://images.unsplash.com/photo-1585647805414-dffb0a2a7a23',
            'timestamp': DateTime.now().subtract(Duration(days: 10)),
            'status': 'Approved',
          },
          {
            'id': 3,
            'amount': 1000.0,
            'date': '01/11/2025',
            'paymentMode': 'Cash',
            'notes': 'Monthly grocery advance',
            'proofPhoto':
                'https://images.pexels.com/photos/4386321/pexels-photo-4386321.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
            'timestamp': DateTime.now().subtract(Duration(days: 17)),
            'status': 'Approved',
          },
          {
            'id': 4,
            'amount': 800.0,
            'date': '25/10/2025',
            'paymentMode': 'UPI',
            'notes': 'Children school fees payment',
            'proofPhoto':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1c6c5aa9c-1763452354208.png',
            'timestamp': DateTime.now().subtract(Duration(days: 24)),
            'status': 'Approved',
          },
        ];
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeletonLoader();
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => isLoading = true);
        _loadUpadRecords();
      },
      child: upadRecords.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildSummaryCard(),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(4.w),
                    itemCount: upadRecords.length,
                    itemBuilder: (context, index) {
                      final upad = upadRecords[index];
                      return _buildUpadCard(upad, index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
    final totalUpad = upadRecords.fold<double>(
        0.0, (sum, upad) => sum + (upad['amount'] as double));
    final thisMonthUpad = upadRecords
        .where((upad) =>
            (upad['timestamp'] as DateTime).month == DateTime.now().month)
        .fold<double>(0.0, (sum, upad) => sum + (upad['amount'] as double));

    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: Colors.white,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Upad Summary',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Upad',
                  '₹${totalUpad.toStringAsFixed(0)}',
                  'account_balance',
                ),
              ),
              Container(
                width: 1,
                height: 6.h,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'This Month',
                  '₹${thisMonthUpad.toStringAsFixed(0)}',
                  'calendar_month',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String icon) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 5.w,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUpadCard(Map<String, dynamic> upad, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showUpadDetails(upad),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with amount and date
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'currency_rupee',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 5.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${(upad['amount'] as double).toStringAsFixed(0)}',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightTheme.colorScheme.secondary,
                          ),
                        ),
                        Text(
                          upad['date'] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(upad['status'] as String)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      upad['status'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(upad['status'] as String),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          icon: 'payment',
                          label: 'Payment Mode',
                          value: upad['paymentMode'] as String,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildInfoChip(
                          icon: 'schedule',
                          label: 'Time',
                          value: _getTimeAgo(upad['timestamp'] as DateTime),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  if ((upad['notes'] as String?)?.isNotEmpty == true) ...[
                    SizedBox(height: 2.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomIconWidget(
                            iconName: 'note',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              upad['notes'] as String,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (upad['proofPhoto'] != null) ...[
                    SizedBox(height: 2.h),
                    GestureDetector(
                      onTap: () =>
                          _showProofImage(upad['proofPhoto'] as String),
                      child: Container(
                        height: 15.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Stack(
                            children: [
                              CustomImageWidget(
                                imageUrl: upad['proofPhoto'] as String,
                                width: double.infinity,
                                height: 15.h,
                                fit: BoxFit.cover,
                                semanticLabel:
                                    "Payment proof document showing transaction receipt or bank transfer confirmation",
                              ),
                              Positioned(
                                top: 2.w,
                                right: 2.w,
                                child: Container(
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'zoom_in',
                                    color: Colors.white,
                                    size: 4.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: color,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
          height: 20.h,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 3.h),
                height: 25.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'account_balance_wallet',
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.4),
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Upad Records',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Advance payment records will appear here',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return AppTheme.lightTheme.colorScheme.onSurface;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showUpadDetails(Map<String, dynamic> upad) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upad Details',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    _buildDetailRow('Amount',
                        '₹${(upad['amount'] as double).toStringAsFixed(2)}'),
                    _buildDetailRow('Date', upad['date'] as String),
                    _buildDetailRow(
                        'Payment Mode', upad['paymentMode'] as String),
                    _buildDetailRow('Status', upad['status'] as String),
                    if ((upad['notes'] as String?)?.isNotEmpty == true)
                      _buildDetailRow('Notes', upad['notes'] as String),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProofImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 70.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImageWidget(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 70.h,
                  fit: BoxFit.contain,
                  semanticLabel: "Full size view of payment proof document",
                ),
              ),
            ),
            Positioned(
              top: 2.h,
              right: 2.h,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomIconWidget(
                    iconName: 'close',
                    color: Colors.white,
                    size: 5.w,
                  ),
                ),
              ),
            ),
          ],
        ),
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
