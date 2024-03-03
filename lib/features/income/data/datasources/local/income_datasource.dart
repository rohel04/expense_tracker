import 'package:expense_tracker/features/income/data/datasources/local/income.dart';
import 'package:hive/hive.dart';
import 'package:expense_tracker/utils/box_constants.dart';

abstract class IncomeDataSource{
  Future<List<Income>> addIncome(income);
  Future<List<Income>> getIncomes();
  Future<List<Income>> updateIncome(index,income);
  Future<List<Income>> deleteIncome(index);
  Future<List<Income>> filter(month);
  


}

class IncomeDataSourceImpl implements IncomeDataSource{
  @override
  Future<List<Income>> addIncome(income) async{
    final incomeBox=Hive.box<Income>(kIncomeBox);
    await incomeBox.put(income.id,income);
    var incomes=getIncomes();
    return incomes;
  }
  
  @override
  Future<List<Income>> getIncomes() async{
    try{
      final incomeBox=Hive.box<Income>(kIncomeBox);
      return incomeBox.values.map((e) => Income(title: e.title, amount: e.amount, date: e.date,futureIncome:e.futureIncome,id: e.id)).toList();
    }catch(e){
      throw Exception();
    }
  }
  
  @override
  Future<List<Income>> updateIncome(id,income) async{
   try{
    final incomeBox=Hive.box<Income>(kIncomeBox);
    await incomeBox.put(id, income);
    return incomeBox.values.map((e) => Income(title: e.title, amount: e.amount, date: e.date,futureIncome: e.futureIncome,id: e.id)).toList();

   }catch(e){
    throw Exception();
   }
  }
  
  @override
  Future<List<Income>> deleteIncome(id) async{
    try{
      final incomeBox=Hive.box<Income>(kIncomeBox);
      await incomeBox.delete(id);
      return await getIncomes();
    }catch(e){
      throw Exception();
    }
  }
  
  @override
  Future<List<Income>> filter(month) async{
    try{
      final incomeBox=Hive.box<Income>(kIncomeBox);
      var incomes= incomeBox.values.map((e) => Income(title: e.title, amount: e.amount, date: e.date, futureIncome: e.futureIncome,id: e.id)).toList();
      return incomes.where((element) => DateTime.parse(element.date).month==month).toList();
    }catch(e){
      throw Exception();
    }
  }
}