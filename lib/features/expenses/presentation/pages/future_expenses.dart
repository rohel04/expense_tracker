import 'package:expense_tracker/features/expenses/data/datasources/local/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/add_expense.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MyFutureExpensesScreen extends StatefulWidget {
  const MyFutureExpensesScreen({super.key});

  @override
  State<MyFutureExpensesScreen> createState() => _MyFutureExpensesScreenState();
}

class _MyFutureExpensesScreenState extends State<MyFutureExpensesScreen> {


  String? totalExpenses;
  List<Expense> futureExpenses=[];
  final TextEditingController _dateController=TextEditingController();

  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpensesLoaded) {
                    if (state.expenses.isEmpty) {
                      return const Center(child: Text('No expenses found'));
                    } else {
                      futureExpenses=state.expenses.where(((element) => element.futureExpense)).toList();
                      futureExpenses.sort((a,b)=>a.date.compareTo(b.date));
                      if (futureExpenses.isEmpty) {
                        return const Center(child: Text('No future expenses found'));
                      }else{
                        return ListView.separated(
                          itemCount: futureExpenses.length,
                          itemBuilder: (context, index) {
                            Expense expense = futureExpenses[index];
                            return Dismissible(
                              movementDuration:const Duration(milliseconds: 100),
                              background: Container(
                                color: Colors.green,
                                padding: const EdgeInsets.only(right: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.mark_email_read_sharp,color: ColorUtil.kTextColor,),
                                    const SizedBox(width: 10),
                                    const Text('Mark as accured')
                                  ],
                                ),
                              ),
                              key: Key(index.toString()),
                              direction: DismissDirection.endToStart,
                            
                              confirmDismiss: (direction) async{
                                DateTime? pickedDate = await showDatePicker(
                                  helpText: 'Select accured date',
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(3000));
                                if (pickedDate != null) {
                                  _dateController.text =
                                      DateFormat("yyyy-MM-dd").format(pickedDate);
                                      update(expense);
                                      return true;
                                }else{
                                  return false;
                                }
                              },
                              
                              child: ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddExpenseScreen(index: index,forUpdate: true,expense: expense,)));
                                },
                                tileColor: ColorUtil.ktileColor,
                                title: Text(expense.title),
                                trailing: IconButton(
                                  onPressed: (){
                                    context.read<ExpenseBloc>().add(DeleteExpenseEvent(id: expense.id));
                                  },
                                  icon:const Icon(Icons.delete,color: Colors.red,)
                                ),
                                subtitle: Text('Rs. ${expense.amount}',style: TextStyle(color: ColorUtil.kTextColor)),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(height: 10);
                          },
                        );

                      }
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            ListTile(
              tileColor: ColorUtil.ktileColor,
              title:const Text('Total future expense'),
              trailing: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if(state is ExpensesLoaded){
                    calculateTotal(futureExpenses);
                    return Text('Rs. $totalExpenses');
                  }else{
                    return const Text('...');
                  }
                },
              ),
            )
          ],
        ),
      );
    
  }

  update(expense){
    context.read<ExpenseBloc>().add(UpdateExpenseEvent(id: expense.id, expense: Expense(title: expense.title, amount: expense.amount, date: _dateController.text, futureExpense: !expense.futureExpense, id: expense.id)));
  }
  calculateTotal(List<Expense> expenses){
    var total = 0;
    for (var i in expenses) {
      total = total + int.parse(i.amount);
    }
    totalExpenses = total.toString();
  }
}
