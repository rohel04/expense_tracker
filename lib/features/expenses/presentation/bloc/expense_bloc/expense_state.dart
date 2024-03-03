part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();
  
  @override
  List<Object> get props => [];
}

class ExpenseInitial extends ExpenseState {}
class ExpensesLoading extends ExpenseState{}
class ExpensesLoaded extends ExpenseState{
  final List<Expense> expenses;

  const ExpensesLoaded({required this.expenses});
  @override
  List<Object> get props => [expenses];
}

class FetchDataComplete extends ExpenseState{
  
}
