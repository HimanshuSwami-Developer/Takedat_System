import 'package:takedat_app/models/payment_model.dart';

abstract class PaymentEvent {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// =====================================================
/// LOAD PAYMENTS (initial / refresh)
/// =====================================================

class LoadPayments extends PaymentEvent {
  const LoadPayments();
}

/// =====================================================
/// LOAD MORE (pagination)
/// =====================================================

class LoadMorePayments extends PaymentEvent {
  const LoadMorePayments();
}

/// =====================================================
/// SEARCH
/// =====================================================

class SearchPayments extends PaymentEvent {
  final String query;

  const SearchPayments(this.query);

  @override
  List<Object?> get props => [query];
}

/// =====================================================
/// UPSERT (create or update)
/// =====================================================

class UpsertPayment extends PaymentEvent {
  final PaymentTrackModel model;

  const UpsertPayment(this.model);

  @override
  List<Object?> get props => [model];
}

/// =====================================================
/// DELETE
/// =====================================================

class DeletePayment extends PaymentEvent {
  final int paymentId;

  const DeletePayment(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}