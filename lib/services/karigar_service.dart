import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class KarigarService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets all karigars with optional filtering
  Future<List<Map<String, dynamic>>> getKarigars({
    String? searchQuery,
    String? skillLevel,
    bool? isActive,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('karigars').select('''
            id,
            employee_id,
            full_name,
            email,
            phone,
            skill_level,
            specialization,
            salary_per_piece,
            base_salary,
            photo_url,
            is_active,
            joining_date,
            created_at
          ''');

      // Apply filters
      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      if (skillLevel != null && skillLevel.isNotEmpty) {
        query = query.eq('skill_level', skillLevel);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'full_name.ilike.%$searchQuery%,employee_id.ilike.%$searchQuery%,phone.ilike.%$searchQuery%');
      }

      // Apply pagination
      if (offset != null) {
        final endOffset = limit != null ? offset + limit - 1 : offset + 19;
        final response = await query.range(offset, endOffset);
        return List<Map<String, dynamic>>.from(response);
      } else if (limit != null) {
        final response = await query.limit(limit);
        return List<Map<String, dynamic>>.from(response);
      }

      // Order by name
      final response = await query.order('full_name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch karigars: $error');
    }
  }

  /// Gets a single karigar by ID
  Future<Map<String, dynamic>?> getKarigar(String id) async {
    try {
      final response = await _client.from('karigars').select('''
            *,
            created_by_profile:user_profiles!karigars_created_by_fkey(full_name)
          ''').eq('id', id).single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch karigar: $error');
    }
  }

  /// Creates a new karigar
  Future<Map<String, dynamic>> createKarigar(Map<String, dynamic> data) async {
    try {
      // Add created_by field
      data['created_by'] = _client.auth.currentUser?.id;

      final response =
          await _client.from('karigars').insert(data).select().single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to create karigar: $error');
    }
  }

  /// Updates an existing karigar
  Future<Map<String, dynamic>> updateKarigar(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('karigars')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to update karigar: $error');
    }
  }

  /// Deletes a karigar (soft delete by setting is_active to false)
  Future<void> deleteKarigar(String id) async {
    try {
      await _client.from('karigars').update({'is_active': false}).eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete karigar: $error');
    }
  }

  /// Gets karigar work statistics
  Future<Map<String, dynamic>> getKarigarStats(String karigarId,
      {DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = _client
          .from('daily_work_entries')
          .select('pieces_completed, total_amount, work_date, quality_rating')
          .eq('karigar_id', karigarId);

      if (startDate != null) {
        query =
            query.gte('work_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query = query.lte('work_date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('work_date', ascending: false);

      int totalPieces = 0;
      double totalEarnings = 0.0;
      double totalRating = 0.0;
      int ratingCount = 0;

      for (var entry in response) {
        totalPieces += (entry['pieces_completed'] as int?) ?? 0;
        totalEarnings += (entry['total_amount'] as num?)?.toDouble() ?? 0.0;

        final rating = entry['quality_rating'] as int?;
        if (rating != null) {
          totalRating += rating;
          ratingCount++;
        }
      }

      return {
        'total_pieces': totalPieces,
        'total_earnings': totalEarnings,
        'average_rating': ratingCount > 0 ? totalRating / ratingCount : 0.0,
        'total_work_days': response.length,
        'work_entries': response,
      };
    } catch (error) {
      throw Exception('Failed to fetch karigar stats: $error');
    }
  }

  /// Gets karigar payments history
  Future<List<Map<String, dynamic>>> getKarigarPayments(String karigarId,
      {int limit = 20}) async {
    try {
      final response = await _client
          .from('upad_payments')
          .select('''
            id,
            amount,
            payment_date,
            payment_type,
            status,
            reason,
            notes,
            created_at
          ''')
          .eq('karigar_id', karigarId)
          .order('payment_date', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch karigar payments: $error');
    }
  }

  /// Gets available karigars for assignment
  Future<List<Map<String, dynamic>>> getAvailableKarigars() async {
    try {
      final response = await _client.from('karigars').select('''
            id,
            employee_id,
            full_name,
            skill_level,
            specialization
          ''').eq('is_active', true).order('full_name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch available karigars: $error');
    }
  }

  /// Gets karigar machine assignment
  Future<Map<String, dynamic>?> getKarigarMachineAssignment(
      String karigarId) async {
    try {
      final response = await _client.from('machine_assignments').select('''
            id,
            assigned_date,
            machines!machine_assignments_machine_id_fkey(
              id,
              machine_number,
              machine_name,
              machine_type
            )
          ''').eq('karigar_id', karigarId).eq('is_active', true).maybeSingle();

      return response != null ? Map<String, dynamic>.from(response) : null;
    } catch (error) {
      throw Exception('Failed to fetch karigar machine assignment: $error');
    }
  }

  /// Gets skill level counts for filtering
  Future<Map<String, int>> getSkillLevelCounts() async {
    try {
      final response = await _client
          .from('karigars')
          .select('skill_level')
          .eq('is_active', true);

      Map<String, int> counts = {
        'beginner': 0,
        'intermediate': 0,
        'advanced': 0,
        'expert': 0,
      };

      for (var karigar in response) {
        final skillLevel = karigar['skill_level'] as String;
        counts[skillLevel] = (counts[skillLevel] ?? 0) + 1;
      }

      return counts;
    } catch (error) {
      throw Exception('Failed to fetch skill level counts: $error');
    }
  }
}