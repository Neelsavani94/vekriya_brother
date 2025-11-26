import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/documents_tab_widget.dart';
import './widgets/monthly_summary_tab_widget.dart';
import './widgets/overview_tab_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/upad_records_tab_widget.dart';
import './widgets/work_history_tab_widget.dart';

class KarigarProfileScreen extends StatefulWidget {
  const KarigarProfileScreen({Key? key}) : super(key: key);

  @override
  State<KarigarProfileScreen> createState() => _KarigarProfileScreenState();
}

class _KarigarProfileScreenState extends State<KarigarProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> karigarData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadKarigarData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadKarigarData() {
    // Simulate loading delay
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        karigarData = {
          'id': 1,
          'name': 'Rajesh Kumar Patel',
          'mobile': '+91 98765 43210',
          'aadhaarNumber': '1234 5678 9012',
          'dateOfBirth': '15/08/1985',
          'gender': 'Male',
          'machineNumber': '05',
          'pieceRate': 15.0,
          'joiningDate': '01/06/2023',
          'employmentType': 'Full Time',
          'shift': 'Day Shift',
          'profilePhoto':
              'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          'address': {
            'street': '123, Textile Colony, Near Mill Gate',
            'city': 'Surat',
            'state': 'Gujarat',
            'pinCode': '395006',
          },
          'bankDetails': {
            'accountHolderName': 'Rajesh Kumar Patel',
            'accountNumber': '1234567890123456',
            'ifscCode': 'SBIN0001234',
            'bankName': 'State Bank of India',
            'branch': 'Textile Market Branch',
          },
          'emergencyContact': {
            'name': 'Priya Patel',
            'relationship': 'Wife',
            'phone': '+91 98765 43211',
          },
        };
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading karigar profile...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ProfileHeaderWidget(
            karigarData: karigarData,
            onEditPressed: _editKarigar,
            onCallPressed: _callKarigar,
            onWhatsAppPressed: _whatsAppKarigar,
          ),

          // Tab Bar
          Container(
            color: AppTheme.lightTheme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.lightTheme.colorScheme.primary,
              unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              indicatorColor: AppTheme.lightTheme.colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle:
                  AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'person',
                        color: _tabController.index == 0
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text('Overview'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'work_history',
                        color: _tabController.index == 1
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text('Work History'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'account_balance_wallet',
                        color: _tabController.index == 2
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text('Upad Records'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'summarize',
                        color: _tabController.index == 3
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text('Monthly Summary'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'folder',
                        color: _tabController.index == 4
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text('Documents'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                OverviewTabWidget(karigarData: karigarData),
                WorkHistoryTabWidget(karigarData: karigarData),
                UpadRecordsTabWidget(karigarData: karigarData),
                MonthlySummaryTabWidget(karigarData: karigarData),
                DocumentsTabWidget(karigarData: karigarData),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button for Quick Actions
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showQuickActions,
      backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      child: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 6.w,
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  _buildQuickActionTile(
                    icon: 'work',
                    title: 'Add Work Entry',
                    subtitle: 'Record daily work and pieces',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/daily-work-entry-screen',
                          arguments: {
                            'karigarId': karigarData['id'],
                            'karigarName': karigarData['name'],
                          });
                    },
                  ),
                  _buildQuickActionTile(
                    icon: 'currency_rupee',
                    title: 'Add Upad Entry',
                    subtitle: 'Record advance payment',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/upad-entry-screen',
                          arguments: {
                            'karigarId': karigarData['id'],
                            'karigarName': karigarData['name'],
                          });
                    },
                  ),
                  _buildQuickActionTile(
                    icon: 'edit',
                    title: 'Edit Profile',
                    subtitle: 'Update karigar information',
                    onTap: () {
                      Navigator.pop(context);
                      _editKarigar();
                    },
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 5.w,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'arrow_forward_ios',
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.4),
        size: 4.w,
      ),
      onTap: onTap,
    );
  }

  void _editKarigar() {
    Navigator.pushNamed(context, '/add-edit-karigar-screen', arguments: {
      'isEdit': true,
      'karigarData': karigarData,
    });
  }

  void _callKarigar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${karigarData['mobile']}...'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Cancel',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _whatsAppKarigar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening WhatsApp chat with ${karigarData['name']}...'),
        backgroundColor: Color(0xFF25D366),
        action: SnackBarAction(
          label: 'Cancel',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
