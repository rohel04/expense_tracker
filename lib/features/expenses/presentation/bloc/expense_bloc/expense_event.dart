part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class AddExpenseEvent extends ExpenseEvent{
  final Expense expense;

  const AddExpenseEvent({required this.expense});
}
class GetExpenseEvent extends ExpenseEvent{
  
}
class UpdateExpenseEvent extends ExpenseEvent{
  final String id;
  final Expense expense;

  const UpdateExpenseEvent({required this.id, required this.expense});
  @override
  List<Object> get props => [id,expense];
}
class DeleteExpenseEvent extends ExpenseEvent{
  final String id;
  

  const DeleteExpenseEvent({required this.id});
  @override
  List<Object> get props => [id];
}

class FilterEvent extends ExpenseEvent{
  final int month;

  const FilterEvent({required this.month});
   
  @override
  List<Object> get props => [month];
}

class BulkAddExpensesEvent extends ExpenseEvent{
  

}