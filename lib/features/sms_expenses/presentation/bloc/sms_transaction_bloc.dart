import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/sms_expenses/data/sms_transaction.dart';
import 'package:expense_tracker/features/sms_expenses/data/sms_transaction_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sms_transaction_event.dart';
part 'sms_transaction_state.dart';

class SmsTransactionBloc
    extends Bloc<SmsTransactionEvent, SmsTransactionState> {
  SmsTransactionDataSource dataSource = SmsTransactionDataSourceImpl();
  List<SmsTransaction> _transactions = [];

  SmsTransactionBloc() : super(SmsTransactionInitial()) {
    on<SyncSmsTransactionsEvent>(_sync);
    on<SetSmsTransactionStatusEvent>(_setStatus);
  }

  Future<void> _sync(
      SyncSmsTransactionsEvent event, Emitter<SmsTransactionState> emit) async {
    emit(SmsTransactionsLoading());
    try {
      _transactions = await dataSource.sync();
      emit(SmsTransactionsLoaded(transactions: _transactions));
    } catch (e) {
      emit(SmsTransactionsError(message: e.toString()));
    }
  }

  Future<void> _setStatus(SetSmsTransactionStatusEvent event,
      Emitter<SmsTransactionState> emit) async {
    try {
      await dataSource.setStatus(event.id, event.status);
      // New instances so Equatable sees a changed state.
      _transactions = _transactions
          .map((txn) => txn.id == event.id ? txn.withStatus(event.status) : txn)
          .toList();
      emit(SmsTransactionsLoaded(transactions: _transactions));
    } catch (e) {
      emit(SmsTransactionsError(message: e.toString()));
    }
  }
}
