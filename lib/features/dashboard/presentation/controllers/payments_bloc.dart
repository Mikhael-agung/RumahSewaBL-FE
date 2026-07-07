import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentsRepository _repository;

  PaymentsBloc({required PaymentsRepository repository})
    : _repository = repository,
      super(const PaymentsState()) {
    on<PaymentsFetched>(_onPaymentsFetched);
    on<PaymentFilterChanged>(_onPaymentFilterChanged);
    on<PaymentVerificationRequested>(_onPaymentVerificationRequested);
  }

  Future<void> _onPaymentsFetched(
    PaymentsFetched event,
    Emitter<PaymentsState> emit,
  ) async {
    final activeFilter = event.status ?? state.selectedFilter;
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: '',
        actionErrorMessage: '',
        selectedFilter: activeFilter,
      ),
    );

    try {
      final payments = await _repository.fetchPayments(status: activeFilter);
      emit(
        state.copyWith(
          isLoading: false,
          payments: payments,
          errorMessage: '',
          selectedFilter: activeFilter,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: _errorMessage(error),
          payments: const [],
          selectedFilter: activeFilter,
        ),
      );
    }
  }

  Future<void> _onPaymentFilterChanged(
    PaymentFilterChanged event,
    Emitter<PaymentsState> emit,
  ) async {
    add(PaymentsFetched(status: event.status));
  }

  Future<void> _onPaymentVerificationRequested(
    PaymentVerificationRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    if (event.paymentId.trim().isEmpty ||
        state.verifyingPaymentIds.contains(event.paymentId)) {
      return;
    }

    final nextVerifying = <String>{
      ...state.verifyingPaymentIds,
      event.paymentId,
    };
    emit(
      state.copyWith(
        verifyingPaymentIds: nextVerifying,
        actionErrorMessage: '',
      ),
    );

    try {
      await _repository.updatePaymentStatus(
        paymentId: event.paymentId,
        status: PaymentVerificationStatus.verified,
      );

      var updatedPayments = state.payments
          .map(
            (item) => item.paymentId == event.paymentId
                ? item.copyWith(status: PaymentVerificationStatus.verified)
                : item,
          )
          .toList(growable: false);

      if (state.selectedFilter == PaymentFilterStatus.pendingVerification) {
        updatedPayments = updatedPayments
            .where((item) => item.paymentId != event.paymentId)
            .toList(growable: false);
      }

      final nextVerifyingAfterSuccess = <String>{...nextVerifying}
        ..remove(event.paymentId);
      emit(
        state.copyWith(
          payments: updatedPayments,
          verifyingPaymentIds: nextVerifyingAfterSuccess,
          actionErrorMessage: '',
        ),
      );
    } catch (error) {
      final nextVerifyingAfterError = <String>{...nextVerifying}
        ..remove(event.paymentId);
      emit(
        state.copyWith(
          verifyingPaymentIds: nextVerifyingAfterError,
          actionErrorMessage: _errorMessage(error),
        ),
      );
    }
  }

  String _errorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

class PaymentsState {
  final bool isLoading;
  final String errorMessage;
  final String actionErrorMessage;
  final List<PaymentVerificationItem> payments;
  final PaymentFilterStatus selectedFilter;
  final Set<String> verifyingPaymentIds;

  const PaymentsState({
    this.isLoading = false,
    this.errorMessage = '',
    this.actionErrorMessage = '',
    this.payments = const [],
    this.selectedFilter = PaymentFilterStatus.all,
    this.verifyingPaymentIds = const <String>{},
  });

  PaymentsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? actionErrorMessage,
    List<PaymentVerificationItem>? payments,
    PaymentFilterStatus? selectedFilter,
    Set<String>? verifyingPaymentIds,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      actionErrorMessage: actionErrorMessage ?? this.actionErrorMessage,
      payments: payments ?? this.payments,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      verifyingPaymentIds: verifyingPaymentIds ?? this.verifyingPaymentIds,
    );
  }
}

abstract class PaymentsEvent {
  const PaymentsEvent();
}

class PaymentsFetched extends PaymentsEvent {
  final PaymentFilterStatus? status;

  const PaymentsFetched({this.status});
}

class PaymentFilterChanged extends PaymentsEvent {
  final PaymentFilterStatus status;

  const PaymentFilterChanged(this.status);
}

class PaymentVerificationRequested extends PaymentsEvent {
  final String paymentId;

  const PaymentVerificationRequested(this.paymentId);
}
