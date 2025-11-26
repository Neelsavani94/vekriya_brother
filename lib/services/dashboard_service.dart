import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class DashboardService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets comprehensive dashboard statistics
  Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final response = await _client.rpc('get_dashboard_statistics');
      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch dashboard statistics: $error');
    }
  }

  /// Gets recent activities for dashboard
  Future<List<Map<String, dynamic>>> getRecentActivities(
      {int limit = 10}) async {
    try {
      final response = await _client.from('activity_logs').select('''
            id,
            action,
            entity_type,
            created_at,
            user_profiles!activity_logs_user_id_fkey(full_name),
            new_data
          ''').order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch recent activities: $error');
    }
  }

  /// Gets karigar count by status
  Future<Map<String, int>> getKarigarStats() async {
    try {
      final totalResponse = await _client
          .from('karigars')
          .select('id')
          .eq('is_active', true)
          .count();

      final activeResponse = await _client
          .from('karigars')
          .select('id')
          .eq('is_active', true)
          .inFilter('id', await _getAssignedKarigarIds())
          .count();

      return {
        'total': totalResponse.count ?? 0,
        'active': activeResponse.count ?? 0,
        'inactive': (totalResponse.count ?? 0) - (activeResponse.count ?? 0),
      };
    } catch (error) {
      throw Exception('Failed to fetch karigar stats: $error');
    }
  }

  /// Gets machine statistics
  Future<Map<String, int>> getMachineStats() async {
    try {
      final totalResponse = await _client
          .from('machines')
          .select('id')
          .eq('is_active', true)
          .count();

      final assignedResponse = await _client
          .from('machines')
          .select('id')
          .eq('status', 'assigned')
          .count();

      return {
        'total': totalResponse.count ?? 0,
        'assigned': assignedResponse.count ?? 0,
        'available': (totalResponse.count ?? 0) - (assignedResponse.count ?? 0),
      };
    } catch (error) {
      throw Exception('Failed to fetch machine stats: $error');
    }
  }

  /// Gets today's production stats
  Future<Map<String, dynamic>> getTodayProduction() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _client
          .from('daily_work_entries')
          .select('pieces_completed, total_amount')
          .eq('work_date', today);

      int totalPieces = 0;
      double totalAmount = 0.0;

      for (var entry in response) {
        totalPieces += (entry['pieces_completed'] as int?) ?? 0;
        totalAmount += (entry['total_amount'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'pieces': totalPieces,
        'amount': totalAmount,
        'target_amount': 25000.0, // Can be configurable
        'progress':
            totalAmount > 0 ? (totalAmount / 25000.0).clamp(0.0, 1.0) : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to fetch today production: $error');
    }
  }

  /// Gets monthly earnings
  Future<Map<String, dynamic>> getMonthlyEarnings() async {
    try {
      final now = DateTime.now();
      final startOfMonth =
          DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];

      final response = await _client
          .from('daily_work_entries')
          .select('total_amount')
          .gte('work_date', startOfMonth);

      double totalAmount = 0.0;
      for (var entry in response) {
        totalAmount += (entry['total_amount'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'amount': totalAmount,
        'target': 500000.0, // Can be configurable
        'progress':
            totalAmount > 0 ? (totalAmount / 500000.0).clamp(0.0, 1.0) : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to fetch monthly earnings: $error');
    }
  }

  /// Gets pending upad payments
  Future<Map<String, dynamic>> getPendingUpads() async {
    try {
      final response = await _client
          .from('upad_payments')
          .select('amount')
          .eq('status', 'pending');

      double totalPending = 0.0;
      for (var payment in response) {
        totalPending += (payment['amount'] as num?)?.toDouble() ?? 0.0;
      }

      final countResponse = await _client
          .from('upad_payments')
          .select('id')
          .eq('status', 'pending')
          .count();

      return {
        'amount': totalPending,
        'count': countResponse.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch pending upads: $error');
    }
  }

  /// Helper method to get assigned karigar IDs
  Future<List<String>> _getAssignedKarigarIds() async {
    try {
      final response = await _client
          .from('machine_assignments')
          .select('karigar_id')
          .eq('is_active', true);

      return response.map((item) => item['karigar_id'] as String).toList();
    } catch (error) {
      return [];
    }
  }

  /// Gets formatted activities for UI display
  Future<List<Map<String, dynamic>>> getFormattedActivities() async {
    try {
      final activities = await getRecentActivities(limit: 5);

      return activities.map((activity) {
        final entityType = activity['entity_type'] as String;
        final action = activity['action'] as String;
        final userName =
            activity['user_profiles']?['full_name'] ?? 'Unknown User';
        final createdAt = DateTime.parse(activity['created_at']);
        final timeAgo = _getTimeAgo(createdAt);

        String title = _getActivityTitle(entityType, action);
        String description = _getActivityDescription(
            entityType, action, userName, activity['new_data']);
        String icon = _getActivityIcon(entityType, action);
        String status = _getActivityStatus(action);

        return {
          'title': title,
          'description': description,
          'timestamp': timeAgo,
          'icon': icon,
          'status': status,
        };
      }).toList();
    } catch (error) {
      // Return mock activities as fallback
      return _getMockActivities();
    }
  }

  String _getActivityTitle(String entityType, String action) {
    switch (entityType) {
      case 'karigars':
        return action == 'created'
            ? 'New Karigar Onboarded'
            : 'Karigar Profile Updated';
      case 'daily_work_entries':
        return 'Production Entry ${action == 'created' ? 'Added' : 'Updated'}';
      case 'upad_payments':
        return 'Payment ${action == 'created' ? 'Processed' : 'Updated'}';
      case 'machines':
        return 'Machine ${action == 'created' ? 'Added' : 'Updated'}';
      default:
        return 'System Activity';
    }
  }

  String _getActivityDescription(
      String entityType, String action, String userName, dynamic newData) {
    try {
      switch (entityType) {
        case 'karigars':
          final name = newData?['full_name'] ?? 'Unknown';
          return '$userName ${action == 'created' ? 'onboarded' : 'updated'} karigar $name';
        case 'daily_work_entries':
          final pieces = newData?['pieces_completed'] ?? 0;
          final amount = newData?['total_amount'] ?? 0;
          return '$userName recorded $pieces pieces worth ₹$amount';
        case 'upad_payments':
          final amount = newData?['amount'] ?? 0;
          return '$userName processed ₹$amount payment';
        case 'machines':
          final machineName = newData?['machine_name'] ?? 'Unknown Machine';
          return '$userName ${action == 'created' ? 'added' : 'updated'} $machineName';
        default:
          return '$userName performed $action on $entityType';
      }
    } catch (e) {
      return '$userName performed $action';
    }
  }

  String _getActivityIcon(String entityType, String action) {
    switch (entityType) {
      case 'karigars':
        return action == 'created' ? 'person_add' : 'person';
      case 'daily_work_entries':
        return 'work_history';
      case 'upad_payments':
        return 'payments';
      case 'machines':
        return 'precision_manufacturing';
      default:
        return 'info';
    }
  }

  String _getActivityStatus(String action) {
    switch (action) {
      case 'created':
        return 'success';
      case 'updated':
        return 'info';
      case 'deleted':
        return 'warning';
      default:
        return 'info';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  List<Map<String, dynamic>> _getMockActivities() {
    return [
      {
        'title': 'Production Milestone Achieved',
        'description':
            'Ramesh Kumar completed 95 shirt pieces on Machine #M001 - Daily target exceeded!',
        'timestamp': '2 hours ago',
        'icon': 'work_history',
        'status': 'success',
      },
      {
        'title': 'Advance Payment Processed',
        'description':
            'Suresh Patel received ₹3500 advance payment for upcoming bulk order',
        'timestamp': '4 hours ago',
        'icon': 'payments',
        'status': 'warning',
      },
      {
        'title': 'New Karigar Onboarded',
        'description':
            'Mukesh Shah joined as Senior Karigar - Specialized in premium fabric stitching',
        'timestamp': '1 day ago',
        'icon': 'person_add',
        'status': 'success',
      },
      {
        'title': 'Machine Assignment Updated',
        'description':
            'High-speed Machine #M003 assigned to experienced Dinesh Kumar for bulk order',
        'timestamp': '2 days ago',
        'icon': 'precision_manufacturing',
        'status': 'info',
      },
    ];
  }
}
