part of 'income_bloc.dart';

abstract class IncomeState extends Equatable {
  const IncomeState();
  
  @override
  List<Object> get props => [];
}

class IncomeInitial extends IncomeState {}

class IncomeLoading extends IncomeState{}
class IncomeLoaded extends IncomeState{
  final List<Income> income;

  const IncomeLoaded({required this.income});
  @override
  List<Object> get props => [income];
}
class IncomeFailure extends IncomeState{}


