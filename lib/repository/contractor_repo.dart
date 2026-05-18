import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/models/contractor_model.dart';
import 'dart:convert';
import 'dart:html' as html;

import 'package:intl/intl.dart';
class ContractorRepository {
  final _supabase = Supabase.instance.client;

  Future<List<ContractorModel>> getContractors({
    int page = 1,
    int limit = 20,
    String search = '',
    double? minAmount,
    double? maxAmount,
    DateTime? payDate,
  }) async {
    final from = (page - 1) * limit;
    final to = from + limit - 1;

    var q = _supabase.from('contractors').select();

    if (search.isNotEmpty) {
      q = q.or(
        'contractor_name.ilike.%$search%,'
        'email.ilike.%$search%,'
        'contact_number.ilike.%$search%',
      );
    }

    if (minAmount != null) q = q.gte('pay_amount', minAmount);
    if (maxAmount != null) q = q.lte('pay_amount', maxAmount);

    if (payDate != null) {
      // ✅ filter by day range in UTC
      final start = DateTime(
        payDate.year,
        payDate.month,
        payDate.day,
      ).toUtc().toIso8601String();
      final end = DateTime(
        payDate.year,
        payDate.month,
        payDate.day + 1,
      ).toUtc().toIso8601String();
      q = q.gte('pay_date', start).lt('pay_date', end);
    }

    final response = await q
        .order('created_at', ascending: false)
        .range(from, to);

    return (response as List)
        .map((e) => ContractorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ContractorModel> createContractor(ContractorModel model) async {
    final payload = model.toJson();
    debugPrint('CREATE PAYLOAD: $payload');

    // ✅ On Flutter Web, .insert().select().single() throws _Namespace
    // Insert first, then fetch the created row separately
    await _supabase.from('contractors').insert(payload);

    // ✅ Fetch the latest inserted row for this email+name combo
    final response = await _supabase
        .from('contractors')
        .select()
        .eq('email', model.email)
        .order('created_at', ascending: false)
        .limit(1)
        .single();

    return ContractorModel.fromJson(response);
  }

  Future<ContractorModel> updateContractor({
    required int id,
    required ContractorModel model,
  }) async {
    final payload = model.toJson();
    debugPrint('UPDATE PAYLOAD: $payload');

    // ✅ Same fix for update
    await _supabase.from('contractors').update(payload).eq('id', id);

    final response = await _supabase
        .from('contractors')
        .select()
        .eq('id', id)
        .single();

    return ContractorModel.fromJson(response);
  }

  Future<void> deleteContractor(int id) async {
    await _supabase.from('contractors').delete().eq('id', id);
  }

  Future<ContractorModel?> getContractorById(int id) async {
    final response = await _supabase
        .from('contractors')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return ContractorModel.fromJson(response);
  }

  // Export all contractors to CSV
  /// =====================================================
  /// EXPORT CSV
  /// =====================================================

  Future<void> exportContractorCsv() async {
    final response = await _supabase
        .from('contractors')
        .select()
        .order('created_at', ascending: false);

    /// CSV HEADERS
    List<List<dynamic>> rows = [
      [
        'ID',
        'Contractor Name',
        'Email',
        'Contact Number',
        'Pay Amount',
        'Pay Date',
        'Pay Slip',
        'Created At',
      ],
    ];

    /// ROWS
    for (final item in response) {
      final contractor = ContractorModel.fromJson(
        Map<String, dynamic>.from(item),
      );

      rows.add([
        contractor.id ?? '',

        contractor.name,

        contractor.email,

        contractor.phone,

        contractor.amount,

        contractor.payDate != null
            ? DateFormat('dd MMM yyyy').format(contractor.payDate!)
            : '',

        contractor.paySlip ?? '',

        contractor.createdAt != null
            ? DateFormat('dd MMM yyyy hh:mm a').format(contractor.createdAt!)
            : '',
      ]);
    }

    /// CSV STRING
    final csvData = rows
        .map(
          (row) => row
              .map((e) {
                final value = e.toString();

                if (value.contains(',') ||
                    value.contains('"') ||
                    value.contains('\n')) {
                  return '"${value.replaceAll('"', '""')}"';
                }

                return value;
              })
              .join(','),
        )
        .join('\n');

    /// DOWNLOAD
    final bytes = utf8.encode(csvData);

    final blob = html.Blob([bytes]);

    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'contractors_${DateTime.now().millisecondsSinceEpoch}.csv'
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}
