import 'package:flutter/material.dart';

import '../presentation/add_edit_karigar_screen/add_edit_karigar_screen.dart';
import '../presentation/daily_work_entry_screen/daily_work_entry_screen.dart';
import '../presentation/karigar_list_screen/karigar_list_screen.dart';
import '../presentation/karigar_profile_screen/karigar_profile_screen.dart';
import '../presentation/main_dashboard/main_dashboard.dart';
import '../presentation/upad_entry_screen/upad_entry_screen.dart';

class AppRoutes {
  static const String karigarProfile = '/karigar-profile-screen';
  static const String mainDashboard = '/main-dashboard';
  static const String karigarList = '/karigar-list-screen';
  static const String dailyWorkEntry = '/daily-work-entry-screen';
  static const String addEditKarigar = '/add-edit-karigar-screen';
  static const String upadEntry = '/upad-entry-screen';

  static Map<String, WidgetBuilder> routes = {
    karigarProfile: (context) => const KarigarProfileScreen(),
    mainDashboard: (context) => const MainDashboard(),
    karigarList: (context) => const KarigarListScreen(),
    dailyWorkEntry: (context) => const DailyWorkEntryScreen(),
    addEditKarigar: (context) => const AddEditKarigarScreen(),
    upadEntry: (context) => const UpadEntryScreen(),
  };
}
