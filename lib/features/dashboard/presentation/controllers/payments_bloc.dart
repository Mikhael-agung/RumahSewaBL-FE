import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rumah_sewa_biru_laut_fe/features/dashboard/presentation/controllers/payments_controller.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final PaymentsRepository _repository;
  PaymentsRepository get repository => _repository;

  PaymentsBloc({required PaymentsRepository repository})
    : _repository = repository,
      super(const PaymentsState()) {
    on<PaymentsFetched>(_onPaymentsFetched);
    on<PaymentFilterChanged>(_onPaymentFilterChanged);
    on<PaymentStatusUpdateRequested>(_onPaymentStatusUpdateRequested);
    on<PaymentExportRequested>(_onPaymentExportRequested);
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
        actionSuccessMessage: '',
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

  Future<void> _onPaymentStatusUpdateRequested(
    PaymentStatusUpdateRequested event,
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
        actionSuccessMessage: '',
      ),
    );

    try {
      await _repository.updatePaymentStatus(
        paymentId: event.paymentId,
        status: event.status,
        rejectionReason: event.rejectionReason,
      );

      var updatedPayments = state.payments
          .map(
            (item) => item.paymentId == event.paymentId
                ? item.copyWith(status: event.status)
                : item,
          )
          .toList(growable: false);

      if (state.selectedFilter != PaymentFilterStatus.all) {
        updatedPayments = updatedPayments
            .where((item) => _isStatusInSelectedFilter(item.status))
            .toList(growable: false);
      }

      final nextVerifyingAfterSuccess = <String>{...nextVerifying}
        ..remove(event.paymentId);
      emit(
        state.copyWith(
          payments: updatedPayments,
          verifyingPaymentIds: nextVerifyingAfterSuccess,
          actionErrorMessage: '',
          actionSuccessMessage:
              event.status == PaymentVerificationStatus.verified
              ? 'Pembayaran berhasil diverifikasi.'
              : 'Pembayaran berhasil ditolak.',
        ),
      );
    } catch (error) {
      final nextVerifyingAfterError = <String>{...nextVerifying}
        ..remove(event.paymentId);
      emit(
        state.copyWith(
          verifyingPaymentIds: nextVerifyingAfterError,
          actionErrorMessage: _errorMessage(error),
          actionSuccessMessage: '',
        ),
      );
    }
  }

  Future<void> _onPaymentExportRequested(
    PaymentExportRequested event,
    Emitter<PaymentsState> emit,
  ) async {
    if (state.isExporting) {
      return;
    }

    emit(
      state.copyWith(
        isExporting: true,
        actionErrorMessage: '',
        actionSuccessMessage: '',
      ),
    );

    try {
      final result = await _repository.exportPayments(
        query:
            event.query ??
            PaymentExportQuery(
              status: (event.status ?? state.selectedFilter).toExportStatus,
            ),
      );
      emit(
        state.copyWith(
          isExporting: false,
          actionErrorMessage: '',
          actionSuccessMessage:
              'Data pembayaran berhasil diekspor (${result.filename}).',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isExporting: false,
          actionErrorMessage: _errorMessage(error),
          actionSuccessMessage: '',
        ),
      );
    }
  }

  String _errorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  bool _isStatusInSelectedFilter(PaymentVerificationStatus status) {
    switch (state.selectedFilter) {
      case PaymentFilterStatus.all:
        return true;
      case PaymentFilterStatus.pendingVerification:
        return status == PaymentVerificationStatus.pending;
      case PaymentFilterStatus.verified:
        return status == PaymentVerificationStatus.verified;
      case PaymentFilterStatus.rejected:
        return status == PaymentVerificationStatus.rejected;
    }
  }
}

class PaymentsState {
  final bool isLoading;
  final String errorMessage;
  final String actionErrorMessage;
  final String actionSuccessMessage;
  final List<PaymentVerificationItem> payments;
  final PaymentFilterStatus selectedFilter;
  final Set<String> verifyingPaymentIds;
  final bool isExporting;

  const PaymentsState({
    this.isLoading = false,
    this.errorMessage = '',
    this.actionErrorMessage = '',
    this.actionSuccessMessage = '',
    this.payments = const [],
    this.selectedFilter = PaymentFilterStatus.all,
    this.verifyingPaymentIds = const <String>{},
    this.isExporting = false,
  });

  PaymentsState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? actionErrorMessage,
    String? actionSuccessMessage,
    List<PaymentVerificationItem>? payments,
    PaymentFilterStatus? selectedFilter,
    Set<String>? verifyingPaymentIds,
    bool? isExporting,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      actionErrorMessage: actionErrorMessage ?? this.actionErrorMessage,
      actionSuccessMessage: actionSuccessMessage ?? this.actionSuccessMessage,
      payments: payments ?? this.payments,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      verifyingPaymentIds: verifyingPaymentIds ?? this.verifyingPaymentIds,
      isExporting: isExporting ?? this.isExporting,
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

class PaymentStatusUpdateRequested extends PaymentsEvent {
  final String paymentId;
  final PaymentVerificationStatus status;
  final String? rejectionReason;

  const PaymentStatusUpdateRequested({
    required this.paymentId,
    required this.status,
    this.rejectionReason,
  });
}

class PaymentExportRequested extends PaymentsEvent {
  final PaymentFilterStatus? status;
  final PaymentExportQuery? query;

  const PaymentExportRequested({this.status, this.query});
}
