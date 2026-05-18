import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:takedat_app/repository/payment_repo.dart';
import 'package:takedat_app/screens/payment/bloc/payment_event.dart';
import 'package:takedat_app/screens/payment/bloc/payment_state.dart';


class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentTrackRepository _repository;

  static const int _pageLimit = 20;

  int _currentPage = 0;
  String _searchQuery = '';

  /// Debounce for search
  Timer? _searchDebounce;

  PaymentBloc({PaymentTrackRepository? repository})
      : _repository = repository ?? PaymentTrackRepository(),
        super(const PaymentInitial()) {
    on<LoadPayments>(_onLoad);
    on<LoadMorePayments>(_onLoadMore);
    on<SearchPayments>(_onSearch);
    on<UpsertPayment>(_onUpsert);
    on<DeletePayment>(_onDelete);
  }

  // =====================================================
  // LOAD (initial / refresh)
  // =====================================================

  Future<void> _onLoad(
    LoadPayments event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());

    _currentPage = 0;

    try {
      final payments = await _repository.getPayments(
        page: _currentPage,
        limit: _pageLimit,
        search: _searchQuery,
      );

      emit(PaymentLoaded(
        payments: payments,
        hasMore: payments.length >= _pageLimit,
      ));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  // =====================================================
  // LOAD MORE (pagination)
  // =====================================================

  Future<void> _onLoadMore(
    LoadMorePayments event,
    Emitter<PaymentState> emit,
  ) async {
    final current = state;
    if (current is! PaymentLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true, clearMessages: true));

    _currentPage++;

    try {
      final newPayments = await _repository.getPayments(
        page: _currentPage,
        limit: _pageLimit,
        search: _searchQuery,
      );

      emit(current.copyWith(
        payments: [...current.payments, ...newPayments],
        hasMore: newPayments.length >= _pageLimit,
        isLoadingMore: false,
      ));
    } catch (e) {
      _currentPage--;
      emit(current.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      ));
    }
  }

  // =====================================================
  // SEARCH (debounced)
  // =====================================================

  void _onSearch(
    SearchPayments event,
    Emitter<PaymentState> emit,
  ) {
    _searchDebounce?.cancel();

    _searchQuery = event.query;

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(const LoadPayments());
    });
  }

  // =====================================================
  // UPSERT
  // =====================================================

  Future<void> _onUpsert(
    UpsertPayment event,
    Emitter<PaymentState> emit,
  ) async {
    final current = state;
    if (current is! PaymentLoaded) return;

    try {
      await _repository.upsertPayment(event.model);

      /// Optimistically update the list
      final updatedList = current.payments.map((p) {
        if (p.attendanceId == event.model.attendanceId) {
          return event.model;
        }
        return p;
      }).toList();

      emit(current.copyWith(
        payments: updatedList,
        successMessage: 'Payment updated successfully',
        clearMessages: false,
      ));
    } catch (e) {
      emit(current.copyWith(
        errorMessage: e.toString(),
        clearMessages: false,
      ));
    }
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<void> _onDelete(
    DeletePayment event,
    Emitter<PaymentState> emit,
  ) async {
    final current = state;
    if (current is! PaymentLoaded) return;

    try {
      await _repository.deletePayment(event.paymentId);

      final updatedList = current.payments
          .where((p) => p.paymentId != event.paymentId)
          .toList();

      emit(current.copyWith(
        payments: updatedList,
        successMessage: 'Payment deleted',
        clearMessages: false,
      ));
    } catch (e) {
      emit(current.copyWith(
        errorMessage: e.toString(),
        clearMessages: false,
      ));
    }
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}