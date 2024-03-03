import 'package:expense_tracker/features/income/data/datasources/local/income.dart';
import 'package:expense_tracker/features/income/data/datasources/local/income_datasource.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


part 'income_event.dart';
part 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {

  final IncomeDataSource dataSource=IncomeDataSourceImpl();

  IncomeBloc() : super(IncomeInitial()) {
    on<IncomeEvent>((event, emit) {
    });
    on<AddIncomeEvent>(_addIncome);
    on<GetIncomeEvent>(_getIncome);
    on<UpdateIncomeEvent>(_updateIncome);
    on<DeleteIncomeEvent>(_deleteIncome);
    on<FilterIncomeEvent>(_filter);
  }

  Future<void> _addIncome(AddIncomeEvent event,Emitter<IncomeState> emit) async{
    emit(IncomeLoading());
    await dataSource.addIncome(event.income);
    var month=DateTime.now().month;
    add(FilterIncomeEvent(month: month));
    
  }
  Future<void> _getIncome(GetIncomeEvent event,Emitter<IncomeState> emit) async{
    emit(IncomeLoading());
    var result=await dataSource.getIncomes();
    emit(IncomeLoaded(income: result));
    
  }
  Future<void> _updateIncome(UpdateIncomeEvent event,Emitter<IncomeState> emit) async{
    emit(IncomeLoading());
    await dataSource.updateIncome(event.id,event.income);
    var month=DateTime.now().month;
    add(FilterIncomeEvent(month: month));
    
  }
  Future<void> _deleteIncome(DeleteIncomeEvent event,Emitter<IncomeState> emit) async{
    emit(IncomeLoading());
    await dataSource.deleteIncome(event.id);
    var month=DateTime.now().month;
    add(FilterIncomeEvent(month: month));
    
  }
   Future<void> _filter(FilterIncomeEvent event,Emitter<IncomeState> emit) async{
    emit(IncomeLoading());
    var result=await dataSource.filter(event.month);
    emit(IncomeLoaded(income: result));
  }

}
