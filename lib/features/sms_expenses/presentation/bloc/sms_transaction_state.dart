part of 'sms_transaction_bloc.dart';

abstract class SmsTransactionState extends Equatable {
  const SmsTransactionState();

  @override
  List<Object> get props => [];
}

class SmsTransactionInitial extends SmsTransactionState {}

class SmsTransactionsLoading extends SmsTransactionState {}

class SmsTransactionsLoaded extends SmsTransactionState {
  final List<SmsTransaction> transactions;

  const SmsTransactionsLoaded({required this.transactions});
  @override
  List<Object> get props => [transactions];
}

class SmsTransactionsError extends SmsTransactionState {
  final String message;

  const SmsTransactionsError({required this.message});
  @override
  List<Object> get props => [message];
}
