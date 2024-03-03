import 'package:expense_tracker/features/expenses/data/datasources/local/expense.dart';
import 'package:hive/hive.dart';
import 'package:expense_tracker/utils/box_constants.dart';

abstract class ExpenseDataSource{
  Future<List<Expense>> bulkAddExpenses(snapshots);
  Future<List<Expense>> addExpense(expense);
  Future<List<Expense>> getExpenses();
  Future<List<Expense>> updateExpense(id,expense);
  Future<List<Expense>> deleteExpense(id);
  Future<List<Expense>> filter(month);
}

class ExpenseDataSourceImpl implements ExpenseDataSource{
  @override
  Future<List<Expense>> addExpense(expense) async{
    final expenseBox=Hive.box<Expense>(kExpenseBox);
    await expenseBox.put(expense.id, expense);
    var expenses=await getExpenses();
    return expenses;
  }
  
  @override
  Future<List<Expense>> getExpenses() async{
    try{
      final expenseBox=Hive.box<Expense>(kExpenseBox);
      return expenseBox.values.map((e) => Expense(title: e.title, amount: e.amount, date: e.date, futureExpense: e.futureExpense,id: e.id,category: e.category)).toList();
    }catch(e){
      throw Exception();
    }
  }
  
  @override
  Future<List<Expense>> updateExpense(id,expense) async{
   try{
    final expenseBox=Hive.box<Expense>(kExpenseBox);
    await expenseBox.put(id, expense) ;
    var expenses=await getExpenses();
    return expenses;

   }catch(e){
    throw Exception();
   }
  }
  
  @override
  Future<List<Expense>> deleteExpense(id) async{
    try{
      final expenseBox=Hive.box<Expense>(kExpenseBox);
      await expenseBox.delete(id) ;
      return await getExpenses();  
    }catch(e){
      throw Exception();
    }
  }
  
  @override
  Future<List<Expense>> filter(month) async{
     try{
      final expenseBox=Hive.box<Expense>(kExpenseBox);
      var expenses= expenseBox.values.map((e) => Expense(title: e.title, amount: e.amount, date: e.date, futureExpense: e.futureExpense,id: e.id,category: e.category)).toList();
      return expenses.where((element) => DateTime.parse(element.date).month==month).toList();
    }catch(e){
      throw Exception();
    }
  }
  
  @override
  Future<List<Expense>> bulkAddExpenses(snapshots) async{
    final expenseBox=Hive.box<Expense>(kExpenseBox);
    try{
      for(var element in snapshots){
        Expense expense=Expense(title: element['title'], amount: element['amount'], date: element['date'], futureExpense: element['future_expense'], id: element['id'],category: element['category']);
         await expenseBox.put(expense.id, expense);
      }
      return expenseBox.values.map((e) => Expense(title: e.title, amount: e.amount, date: e.date, futureExpense: e.futureExpense,id: e.id,category: e.category)).toList();
    }catch(e){
      throw Exception();
    }
  }
}