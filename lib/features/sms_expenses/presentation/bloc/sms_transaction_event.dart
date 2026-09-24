part of 'sms_transaction_bloc.dart';

abstract class SmsTransactionEvent extends Equatable {
  const SmsTransactionEvent();

  @override
  List<Object> get props => [];
}

class SyncSmsTransactionsEvent extends SmsTransactionEvent {}

class SetSmsTransactionStatusEvent extends SmsTransactionEvent {
  final String id;
  final SmsTransactionStatus status;

  const SetSmsTransactionStatusEvent({required this.id, required this.status});
  @override
  List<Object> get props => [id, status];
}
