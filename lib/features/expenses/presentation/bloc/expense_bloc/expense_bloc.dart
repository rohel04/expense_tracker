import 'package:equatable/equatable.dart';
import 'package:expense_tracker/common/datasource/sync_datasource.dart';
import 'package:expense_tracker/features/expenses/data/datasources/local/expense_datasource.dart';
import 'package:expense_tracker/features/expenses/data/datasources/local/expense.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {


   ExpenseDataSource dataSource=ExpenseDataSourceImpl();
  SyncRemoteDataSource syncDataSource=SyncRemoteDataSourceImpl();
  var month=DateTime.now().month;

  ExpenseBloc() : super(ExpenseInitial()) {
    on<ExpenseEvent>((event, emit) {
    });
    on<AddExpenseEvent>(_addExpense);
    on<GetExpenseEvent>(_getExpense);
    on<UpdateExpenseEvent>(_updateExpense);
    on<BulkAddExpensesEvent>(_bulkAddExpenses);
    on<DeleteExpenseEvent>(_deleteExpense);
    on<FilterEvent>(_filter);
  }
  Future<void> _addExpense(AddExpenseEvent event,Emitter<ExpenseState> emit) async{
    emit(ExpensesLoading());
    await dataSource.addExpense(event.expense);
    add(FilterEvent(month: month));
  }

   Future<void> _bulkAddExpenses(BulkAddExpensesEvent event,Emitter<ExpenseState> emit) async{
    emit(ExpensesLoading());
    await syncDataSource.getFromRemote();
    emit(FetchDataComplete());
  }

  Future<void> _getExpense(GetExpenseEvent event,Emitter<ExpenseState> emit) async{
    emit(ExpensesLoading());
    await dataSource.getExpenses();
    add(FilterEvent(month: month));
  }
  Future<void> _updateExpense(UpdateExpenseEvent event,Emitter<ExpenseState> emit) async{
    emit(ExpensesLoading());
    await dataSource.updateExpense(event.id, event.expense);
    add(FilterEvent(month: month));
  }
  Future<void> _deleteExpense(DeleteExpenseEvent event,Emitter<ExpenseState> emit) async{
    emit(ExpensesLoading());
    await dataSource.deleteExpense(event.id);
    add(FilterEvent(month: month));
    
  }
  Future<void> _filter(FilterEvent event,Emitter<ExpenseState> emit) async{
    emit(ExpensesLoading());
    var result=await dataSource.filter(event.month);
    emit(ExpensesLoaded(expenses: result));
  }

}
