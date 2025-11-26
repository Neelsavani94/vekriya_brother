import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class DailyWorkService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets all daily work entries with optional filtering
  Future<List<Map<String, dynamic>>> getDailyWorkEntries({
    String? karigarId,
    DateTime? startDate,
    DateTime? endDate,
    String? workType,
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('daily_work_entries').select('''
            id,
            work_date,
            work_type,
            pieces_completed,
            hours_worked,
            rate_per_piece,
            total_amount,
            quality_rating,
            status,
            notes,
            created_at,
            karigars!daily_work_entries_karigar_id_fkey(
              id,
              full_name,
              employee_id
            ),
            machines!daily_work_entries_machine_id_fkey(
              id,
              machine_name,
              machine_number
            )
          ''');

      // Apply filters
      if (karigarId != null) {
        query = query.eq('karigar_id', karigarId);
      }

      if (startDate != null) {
        query =
            query.gte('work_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('work_date', endDate.toIso8601String().split('T')[0]);
      }

      if (workType != null && workType.isNotEmpty && workType != 'all') {
        query = query.eq('work_type', workType);
      }

      if (status != null && status.isNotEmpty && status != 'all') {
        query = query.eq('status', status);
      }

      // Apply pagination
      if (offset != null) {
        final endOffset = limit != null ? offset + limit - 1 : offset + 19;
        final response = await query.range(offset, endOffset).order('work_date', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      } else if (limit != null) {
        final response = await query.limit(limit).order('work_date', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }

      // Order by work date descending
      final response = await query.order('work_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch daily work entries: $error');
    }
  }

  /// Gets a single daily work entry by ID
  Future<Map<String, dynamic>?> getDailyWorkEntry(String id) async {
    try {
      final response = await _client.from('daily_work_entries').select('''
            *,
            karigars!daily_work_entries_karigar_id_fkey(
              id,
              full_name,
              employee_id,
              salary_per_piece
            ),
            machines!daily_work_entries_machine_id_fkey(
              id,
              machine_name,
              machine_number,
              machine_type
            ),
            created_by_profile:user_profiles!daily_work_entries_created_by_fkey(full_name)
          ''').eq('id', id).single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch daily work entry: $error');
    }
  }

  /// Creates a new daily work entry
  Future<Map<String, dynamic>> createDailyWorkEntry(
      Map<String, dynamic> data) async {
    try {
      // Add created_by field
      data['created_by'] = _client.auth.currentUser?.id;

      // Calculate total amount if not provided
      if (data['total_amount'] == null) {
        final piecesCompleted = data['pieces_completed'] as int? ?? 0;
        final ratePerPiece = data['rate_per_piece'] as double? ?? 0.0;
        data['total_amount'] = piecesCompleted * ratePerPiece;
      }

      final response =
          await _client.from('daily_work_entries').insert(data).select('''
            *,
            karigars!daily_work_entries_karigar_id_fkey(full_name, employee_id),
            machines!daily_work_entries_machine_id_fkey(machine_name, machine_number)
          ''').single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to create daily work entry: $error');
    }
  }

  /// Updates an existing daily work entry
  Future<Map<String, dynamic>> updateDailyWorkEntry(
      String id, Map<String, dynamic> data) async {
    try {
      // Recalculate total amount if pieces or rate changed
      if (data.containsKey('pieces_completed') ||
          data.containsKey('rate_per_piece')) {
        // Get current entry to get missing values
        final currentEntry = await _client
            .from('daily_work_entries')
            .select('pieces_completed, rate_per_piece')
            .eq('id', id)
            .single();

        final piecesCompleted =
            data['pieces_completed'] ?? currentEntry['pieces_completed'] ?? 0;
        final ratePerPiece =
            data['rate_per_piece'] ?? currentEntry['rate_per_piece'] ?? 0.0;
        data['total_amount'] = piecesCompleted * ratePerPiece;
      }

      final response = await _client
          .from('daily_work_entries')
          .update(data)
          .eq('id', id)
          .select('''
            *,
            karigars!daily_work_entries_karigar_id_fkey(full_name, employee_id),
            machines!daily_work_entries_machine_id_fkey(machine_name, machine_number)
          ''').single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to update daily work entry: $error');
    }
  }

  /// Deletes a daily work entry
  Future<void> deleteDailyWorkEntry(String id) async {
    try {
      await _client.from('daily_work_entries').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete daily work entry: $error');
    }
  }

  /// Gets work statistics for a specific period
  Future<Map<String, dynamic>> getWorkStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? karigarId,
  }) async {
    try {
      var query = _client
          .from('daily_work_entries')
          .select('pieces_completed, total_amount, work_type, karigar_id');

      if (startDate != null) {
        query =
            query.gte('work_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('work_date', endDate.toIso8601String().split('T')[0]);
      }

      if (karigarId != null) {
        query = query.eq('karigar_id', karigarId);
      }

      final response = await query;

      int totalPieces = 0;
      double totalAmount = 0.0;
      Map<String, int> workTypeCount = {};
      Set<String> uniqueKarigars = {};

      for (var entry in response) {
        totalPieces += (entry['pieces_completed'] as int?) ?? 0;
        totalAmount += (entry['total_amount'] as num?)?.toDouble() ?? 0.0;

        final workType = entry['work_type'] as String?;
        if (workType != null) {
          workTypeCount[workType] = (workTypeCount[workType] ?? 0) + 1;
        }

        final kagerId = entry['karigar_id'] as String?;
        if (kagerId != null) {
          uniqueKarigars.add(kagerId);
        }
      }

      return {
        'total_pieces': totalPieces,
        'total_amount': totalAmount,
        'total_entries': response.length,
        'unique_karigars': uniqueKarigars.length,
        'work_type_breakdown': workTypeCount,
      };
    } catch (error) {
      throw Exception('Failed to fetch work statistics: $error');
    }
  }

  /// Gets recent work entries
  Future<List<Map<String, dynamic>>> getRecentWorkEntries(
      {int limit = 10}) async {
    try {
      final response = await _client.from('daily_work_entries').select('''
            id,
            work_date,
            work_type,
            pieces_completed,
            total_amount,
            karigars!daily_work_entries_karigar_id_fkey(full_name)
          ''').order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch recent work entries: $error');
    }
  }

  /// Gets available machines for work entry
  Future<List<Map<String, dynamic>>> getAvailableMachines() async {
    try {
      final response = await _client.from('machines').select('''
            id,
            machine_number,
            machine_name,
            machine_type,
            status
          ''').eq('is_active', true).order('machine_number', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch available machines: $error');
    }
  }
}