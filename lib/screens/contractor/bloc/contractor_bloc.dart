import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/models/contractor_model.dart';
import 'package:takedat_app/repository/contractor_repo.dart';
import 'contractor_event.dart';
import 'contractor_state.dart';

class ContractorBloc extends Bloc<ContractorEvent, ContractorState> {
  final ContractorRepository repository;

  List<ContractorModel> contractors = [];
  int currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  String currentSearch = '';
  double? filterMinAmount;
  double? filterMaxAmount;
  DateTime? filterPayDate;

  ContractorBloc(this.repository) : super(ContractorInitial()) {
    /// ─────────────────────────────────────
    /// LOAD
    /// ─────────────────────────────────────
    on<LoadContractorsEvent>((event, emit) async {
      emit(ContractorLoading());
      try {
        currentPage = 1;
        hasMore = true;
        currentSearch = '';
        filterMinAmount = null;
        filterMaxAmount = null;
        filterPayDate = null;

        contractors = await repository.getContractors(page: currentPage);

        if (contractors.length < 20) hasMore = false;

        emit(ContractorLoaded(contractors: contractors, hasMore: hasMore));
      } catch (e) {
        emit(ContractorFailure(e.toString()));
      }
    });

    /// ─────────────────────────────────────
    /// LOAD MORE
    /// ─────────────────────────────────────
    on<LoadMoreContractorsEvent>((event, emit) async {
      if (isLoadingMore || !hasMore) return;
      try {
        isLoadingMore = true;
        currentPage++;

        final more = await repository.getContractors(
          page: currentPage,
          search: currentSearch,
          minAmount: filterMinAmount,
          maxAmount: filterMaxAmount,
          payDate: filterPayDate,
        );

        if (more.length < 20) hasMore = false;
        contractors.addAll(more);

        emit(ContractorLoaded(contractors: contractors, hasMore: hasMore));
        isLoadingMore = false;
      } catch (e) {
        isLoadingMore = false;
        emit(ContractorFailure(e.toString()));
      }
    });

    /// ─────────────────────────────────────
    /// SEARCH
    /// ─────────────────────────────────────
    on<SearchContractorsEvent>((event, emit) async {
      emit(ContractorLoading());
      try {
        currentSearch = event.query;
        currentPage = 1;
        hasMore = true;

        contractors = await repository.getContractors(
          page: currentPage,
          search: currentSearch,
          minAmount: filterMinAmount,
          maxAmount: filterMaxAmount,
          payDate: filterPayDate,
        );

        if (contractors.length < 20) hasMore = false;

        emit(ContractorLoaded(contractors: contractors, hasMore: hasMore));
      } catch (e) {
        emit(ContractorFailure(e.toString()));
      }
    });

    /// ─────────────────────────────────────
    /// FILTER
    /// ─────────────────────────────────────
    on<FilterContractorsEvent>((event, emit) async {
      emit(ContractorLoading());
      try {
        filterMinAmount = event.minAmount;
        filterMaxAmount = event.maxAmount;
        filterPayDate = event.payDate;
        currentPage = 1;
        hasMore = true;

        contractors = await repository.getContractors(
          page: currentPage,
          search: currentSearch,
          minAmount: filterMinAmount,
          maxAmount: filterMaxAmount,
          payDate: filterPayDate,
        );

        if (contractors.length < 20) hasMore = false;

        emit(ContractorLoaded(contractors: contractors, hasMore: hasMore));
      } catch (e) {
        emit(ContractorFailure(e.toString()));
      }
    });

    /// ─────────────────────────────────────
    /// CREATE
    /// ─────────────────────────────────────

    // ✅ Change all File? to XFile?
    on<CreateContractorEvent>((event, emit) async {
      try {
        String? paySlipUrl;
        if (event.paySlipFile != null) {
          paySlipUrl = await _uploadPaySlip(
            event.paySlipFile!,
            event.model.email,
          );
        }
        final model = event.model.copyWith(paySlip: paySlipUrl);
        final created = await repository.createContractor(model);
        contractors.insert(0, created);
        emit(ContractorLoaded(contractors: contractors, hasMore: hasMore));
      } catch (e) {
        debugPrint('CREATE CONTRACTOR ERROR: $e');
        emit(ContractorFailure(e.toString()));
      }
    });

    on<UpdateContractorEvent>((event, emit) async {
      try {
        String? paySlipUrl = event.model.paySlip;
        if (event.paySlipFile != null) {
          paySlipUrl = await _uploadPaySlip(
            event.paySlipFile!,
            event.model.email,
          );
        }
        final model = event.model.copyWith(paySlip: paySlipUrl);
        final updated = await repository.updateContractor(
          id: event.id,
          model: model,
        );
        final index = contractors.indexWhere((e) => e.id == updated.id);
        if (index != -1) contractors[index] = updated;
        emit(ContractorLoaded(contractors: contractors, hasMore: hasMore));
      } catch (e) {
        emit(ContractorFailure(e.toString()));
      }
    });

    /// ─────────────────────────────────────
    /// DELETE
    /// ─────────────────────────────────────
    on<DeleteContractorEvent>((event, emit) async {
      try {
        await repository.deleteContractor(event.id);
        contractors.removeWhere((e) => e.id == event.id);
        emit(ContractorLoaded(contractors: contractors, hasMore: hasMore));
      } catch (e) {
        emit(ContractorFailure(e.toString()));
      }
    });
  }

  // ✅ Upload using readAsBytes — works on web AND mobile
  Future<String> _uploadPaySlip(XFile file, String email) async {
    final supabase = Supabase.instance.client;

    final bytes = await file.readAsBytes();

    /// CLEAN EMAIL
    final safeEmail = email.replaceAll('@', '_').replaceAll('.', '_');

    /// UNIQUE FILE NAME
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    /// FINAL STORAGE PATH
    final path = 'payslips/$safeEmail/$fileName';

    await supabase.storage
        .from('contractors')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('contractors').getPublicUrl(path);
  }
}
