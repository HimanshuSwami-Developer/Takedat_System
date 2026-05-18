
import 'package:takedat_app/models/payment_model.dart';

abstract class PaymentState {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// =====================================================
/// INITIAL
/// =====================================================

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// =====================================================
/// LOADING (initial / refresh)
/// =====================================================

class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// =====================================================
/// LOADED
/// =====================================================

class PaymentLoaded extends PaymentState {
  final List<PaymentTrackModel> payments;

  /// Pagination
  final bool hasMore;
  final bool isLoadingMore;

  /// Action feedback
  final String? successMessage;
  final String? errorMessage;

  const PaymentLoaded({
    required this.payments,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.successMessage,
    this.errorMessage,
  });

  PaymentLoaded copyWith({
    List<PaymentTrackModel>? payments,
    bool? hasMore,
    bool? isLoadingMore,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return PaymentLoaded(
      payments: payments ?? this.payments,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      successMessage: clearMessages ? null : successMessage ?? this.successMessage,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        payments,
        hasMore,
        isLoadingMore,
        successMessage,
        errorMessage,
      ];
}

/// =====================================================
/// ERROR
/// =====================================================

class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}