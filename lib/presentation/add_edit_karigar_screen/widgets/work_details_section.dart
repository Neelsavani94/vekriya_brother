import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WorkDetailsSection extends StatelessWidget {
  final TextEditingController pieceRateController;
  final String? selectedMachine;
  final DateTime? joiningDate;
  final String? pieceRateError;
  final String? machineError;
  final String? joiningDateError;
  final Function(String) onPieceRateChanged;
  final Function(String?) onMachineChanged;
  final Function(DateTime?) onJoiningDateChanged;
  final VoidCallback onDateTap;

  const WorkDetailsSection({
    Key? key,
    required this.pieceRateController,
    this.selectedMachine,
    this.joiningDate,
    this.pieceRateError,
    this.machineError,
    this.joiningDateError,
    required this.onPieceRateChanged,
    required this.onMachineChanged,
    required this.onJoiningDateChanged,
    required this.onDateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> availableMachines = [
      {
        "id": "M001",
        "name": "Machine 1 - Single Needle",
        "status": "Available"
      },
      {"id": "M002", "name": "Machine 2 - Overlock", "status": "Available"},
      {
        "id": "M003",
        "name": "Machine 3 - Button Hole",
        "status": "Assigned to Ramesh"
      },
      {"id": "M004", "name": "Machine 4 - Zigzag", "status": "Available"},
      {"id": "M005", "name": "Machine 5 - Serger", "status": "Available"},
    ];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Work Details',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
            SizedBox(height: 2.h),

            // Piece Rate Field
            TextFormField(
              controller: pieceRateController,
              onChanged: onPieceRateChanged,
              decoration: InputDecoration(
                labelText: 'Piece Rate (₹) *',
                hintText: 'Enter rate per piece',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'currency_rupee',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: pieceRateError,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),

            // Machine Assignment Dropdown
            DropdownButtonFormField<String>(
              value: selectedMachine,
              onChanged: onMachineChanged,
              decoration: InputDecoration(
                labelText: 'Machine Assignment *',
                hintText: 'Select machine',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'precision_manufacturing',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 20,
                  ),
                ),
                errorText: machineError,
              ),
              items: availableMachines.map((machine) {
                final isAvailable =
                    (machine["status"] as String) == "Available";
                return DropdownMenuItem<String>(
                  value: machine["id"] as String,
                  enabled: isAvailable,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        machine["name"] as String,
                        style: TextStyle(
                          color: isAvailable
                              ? AppTheme.lightTheme.colorScheme.onSurface
                              : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        machine["status"] as String,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isAvailable
                              ? AppTheme.successLight
                              : AppTheme.warningLight,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 2.h),

            // Joining Date Field
            InkWell(
              onTap: onDateTap,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Joining Date *',
                  hintText: 'Select joining date',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'calendar_today',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  errorText: joiningDateError,
                ),
                child: Text(
                  joiningDate != null
                      ? '${joiningDate!.day.toString().padLeft(2, '0')}/${joiningDate!.month.toString().padLeft(2, '0')}/${joiningDate!.year}'
                      : 'Select joining date',
                  style: TextStyle(
                    color: joiningDate != null
                        ? AppTheme.lightTheme.colorScheme.onSurface
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
