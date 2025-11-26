import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class UpadService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets all upad payments with optional filtering
  Future<List<Map<String, dynamic>>> getUpadPayments({
    String? karigarId,
    DateTime? startDate,
    DateTime? endDate,
    String? paymentType,
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('upad_payments').select('''
            id,
            amount,
            payment_date,
            payment_type,
            status,
            reason,
            notes,
            proof_document_url,
            created_at,
            karigars!upad_payments_karigar_id_fkey(
              id,
              full_name,
              employee_id
            ),
            created_by_profile:user_profiles!upad_payments_created_by_fkey(full_name)
          ''');

      // Apply filters
      if (karigarId != null) {
        query = query.eq('karigar_id', karigarId);
      }

      if (startDate != null) {
        query = query.gte(
            'payment_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query =
            query.lte('payment_date', endDate.toIso8601String().split('T')[0]);
      }

      if (paymentType != null &&
          paymentType.isNotEmpty &&
          paymentType != 'all') {
        query = query.eq('payment_type', paymentType);
      }

      if (status != null && status.isNotEmpty && status != 'all') {
        query = query.eq('status', status);
      }

      // Order by payment date descending and apply pagination in one chain
      if (offset != null) {
        final endOffset = limit != null ? offset + limit - 1 : offset + 19;
        final response = await query
            .order('payment_date', ascending: false)
            .range(offset, endOffset);
        return List<Map<String, dynamic>>.from(response);
      } else if (limit != null) {
        final response =
            await query.order('payment_date', ascending: false).limit(limit);
        return List<Map<String, dynamic>>.from(response);
      } else {
        final response = await query.order('payment_date', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (error) {
      throw Exception('Failed to fetch upad payments: $error');
    }
  }

  /// Gets a single upad payment by ID
  Future<Map<String, dynamic>?> getUpadPayment(String id) async {
    try {
      final response = await _client.from('upad_payments').select('''
            *,
            karigars!upad_payments_karigar_id_fkey(
              id,
              full_name,
              employee_id,
              phone,
              base_salary
            ),
            created_by_profile:user_profiles!upad_payments_created_by_fkey(full_name)
          ''').eq('id', id).single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch upad payment: $error');
    }
  }

  /// Creates a new upad payment
  Future<Map<String, dynamic>> createUpadPayment(
      Map<String, dynamic> data) async {
    try {
      // Add created_by field
      data['created_by'] = _client.auth.currentUser?.id;

      // Set default status if not provided
      if (data['status'] == null) {
        data['status'] = 'paid';
      }

      // Set default payment type if not provided
      if (data['payment_type'] == null) {
        data['payment_type'] = 'advance';
      }

      final response =
          await _client.from('upad_payments').insert(data).select('''
            *,
            karigars!upad_payments_karigar_id_fkey(full_name, employee_id),
            created_by_profile:user_profiles!upad_payments_created_by_fkey(full_name)
          ''').single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to create upad payment: $error');
    }
  }

  /// Updates an existing upad payment
  Future<Map<String, dynamic>> updateUpadPayment(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('upad_payments')
          .update(data)
          .eq('id', id)
          .select('''
            *,
            karigars!upad_payments_karigar_id_fkey(full_name, employee_id),
            created_by_profile:user_profiles!upad_payments_created_by_fkey(full_name)
          ''').single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to update upad payment: $error');
    }
  }

  /// Deletes a upad payment
  Future<void> deleteUpadPayment(String id) async {
    try {
      await _client.from('upad_payments').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete upad payment: $error');
    }
  }

  /// Gets payment statistics for a specific period
  Future<Map<String, dynamic>> getPaymentStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? karigarId,
  }) async {
    try {
      var query = _client
          .from('upad_payments')
          .select('amount, payment_type, status, karigar_id');

      if (startDate != null) {
        query = query.gte(
            'payment_date', startDate.toIso8601String().split('T')[0]);
      }

      if (endDate != null) {
        query =
            query.lte('payment_date', endDate.toIso8601String().split('T')[0]);
      }

      if (karigarId != null) {
        query = query.eq('karigar_id', karigarId);
      }

      final response = await query;

      double totalAmount = 0.0;
      Map<String, double> paymentTypeAmounts = {};
      Map<String, int> statusCounts = {};
      Set<String> uniqueKarigars = {};

      for (var payment in response) {
        final amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
        totalAmount += amount;

        final paymentType = payment['payment_type'] as String?;
        if (paymentType != null) {
          paymentTypeAmounts[paymentType] =
              (paymentTypeAmounts[paymentType] ?? 0.0) + amount;
        }

        final status = payment['status'] as String?;
        if (status != null) {
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }

        final karigarId = payment['karigar_id'] as String?;
        if (karigarId != null) {
          uniqueKarigars.add(karigarId);
        }
      }

      return {
        'total_amount': totalAmount,
        'total_payments': response.length,
        'unique_karigars': uniqueKarigars.length,
        'payment_type_breakdown': paymentTypeAmounts,
        'status_breakdown': statusCounts,
      };
    } catch (error) {
      throw Exception('Failed to fetch payment statistics: $error');
    }
  }

  /// Gets recent upad payments
  Future<List<Map<String, dynamic>>> getRecentUpadPayments(
      {int limit = 10}) async {
    try {
      final response = await _client.from('upad_payments').select('''
            id,
            amount,
            payment_date,
            payment_type,
            status,
            reason,
            karigars!upad_payments_karigar_id_fkey(full_name)
          ''').order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch recent upad payments: $error');
    }
  }

  /// Gets total advance amount for a karigar
  Future<double> getKarigarAdvanceBalance(String karigarId) async {
    try {
      final response = await _client
          .from('upad_payments')
          .select('amount')
          .eq('karigar_id', karigarId)
          .eq('payment_type', 'advance')
          .eq('status', 'paid');

      double totalAdvance = 0.0;
      for (var payment in response) {
        totalAdvance += (payment['amount'] as num?)?.toDouble() ?? 0.0;
      }

      return totalAdvance;
    } catch (error) {
      throw Exception('Failed to fetch karigar advance balance: $error');
    }
  }

  /// Gets payment summary for karigar
  Future<Map<String, dynamic>> getKarigarPaymentSummary(
      String karigarId) async {
    try {
      final response = await _client
          .from('upad_payments')
          .select('amount, payment_type, status')
          .eq('karigar_id', karigarId);

      double totalAdvance = 0.0;
      double totalPaid = 0.0;
      double totalPending = 0.0;
      int paymentCount = 0;

      for (var payment in response) {
        final amount = (payment['amount'] as num?)?.toDouble() ?? 0.0;
        final paymentType = payment['payment_type'] as String?;
        final status = payment['status'] as String?;

        paymentCount++;

        if (paymentType == 'advance') {
          totalAdvance += amount;
        }

        if (status == 'paid') {
          totalPaid += amount;
        } else if (status == 'pending') {
          totalPending += amount;
        }
      }

      return {
        'total_advance': totalAdvance,
        'total_paid': totalPaid,
        'total_pending': totalPending,
        'payment_count': paymentCount,
      };
    } catch (error) {
      throw Exception('Failed to fetch karigar payment summary: $error');
    }
  }
}
