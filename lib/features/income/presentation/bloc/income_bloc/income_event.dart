part of 'income_bloc.dart';

abstract class IncomeEvent extends Equatable {
  const IncomeEvent();

  @override
  List<Object> get props => [];
}

class GetIncomeEvent extends IncomeEvent{}
class AddIncomeEvent extends IncomeEvent{
  final Income income;

  const AddIncomeEvent({required this.income});
  @override
  List<Object> get props => [income];
}
class UpdateIncomeEvent extends IncomeEvent{
  final Income income;
  final String id;

  const UpdateIncomeEvent({required this.id, required this.income});
  @override
  List<Object> get props => [income,id];
}
class DeleteIncomeEvent extends IncomeEvent{
  final String id;

  const DeleteIncomeEvent({required this.id});
  @override
  List<Object> get props => [id];
}

class FilterIncomeEvent extends IncomeEvent{
  final int month;

  const FilterIncomeEvent({required this.month});
   @override
  List<Object> get props => [month];
}

class BulkAddIncomEvent extends IncomeEvent{
  
}
