import 'package:expense_tracker/features/expenses/data/datasources/local/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/add_expense.dart';
import 'package:expense_tracker/features/expenses/presentation/pages/future_expenses.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyExpensesScreen extends StatefulWidget {
  const MyExpensesScreen({super.key});

  @override
  State<MyExpensesScreen> createState() => _MyExpensesScreenState();
}

class _MyExpensesScreenState extends State<MyExpensesScreen> {
  String? totalExpenses;

  List<Expense> currentExpenses = [];
  String? filterDate;
  int monthValue = 0;
  List<String> month = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    monthValue = DateTime.now().month;
    context.read<ExpenseBloc>().add(FilterEvent(month: monthValue));
    filterDate = month[monthValue - 1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Expenses'),
            bottom: const TabBar(
                tabs: [Tab(text: 'Completed'), Tab(text: 'Future')]),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddExpenseScreen()));
                  },
                  icon: const Icon(Icons.add))
            ],
          ),
          backgroundColor: ColorUtil.kPrmiaryColor,
          body: TabBarView(
              children: [expenses(), const MyFutureExpensesScreen()])),
    );
  }

  calculateTotal(List<Expense> expenses) {
    var total = 0;
    for (var i in expenses) {
      total = total + int.parse(i.amount);
    }
    totalExpenses = total.toString();
  }

  Widget expenses() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                return DropdownButton(
                    style: TextStyle(color: Colors.white),
                    value: filterDate,
                    items: month
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(color: Colors.orangeAccent),
                            )))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        filterDate = value;
                        monthValue = month.indexOf(filterDate!) + 1;
                      });
                      context
                          .read<ExpenseBloc>()
                          .add(FilterEvent(month: monthValue));
                    });
              },
            ),
          ),
          Expanded(
            child: Material(
              color: ColorUtil.kPrmiaryColor,
              child: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpensesLoaded) {
                    if (state.expenses.isEmpty) {
                      return const Center(child: Text('No expenses found'));
                    } else {
                      currentExpenses = state.expenses
                          .where((element) => !element.futureExpense)
                          .toList();
                      currentExpenses
                          .sort(((a, b) => a.date.compareTo(b.date)));
                      if (currentExpenses.isEmpty) {
                        return const Center(
                            child: Text('No completed expenses found'));
                      } else {
                        return ListView.separated(
                          itemCount: currentExpenses.length,
                          itemBuilder: (context, index) {
                            Expense expense = currentExpenses[index];
                            return Dismissible(
                              movementDuration:
                                  const Duration(milliseconds: 100),
                              background: Container(
                                color: Colors.red,
                                child: const Icon(Icons.delete),
                              ),
                              confirmDismiss: (direction) async {
                                bool result = false;
                                await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'You sure want to delete?',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        actions: [
                                          InkWell(
                                            onTap: () {
                                              result = true;
                                              Navigator.pop(context);
                                            },
                                            child: const Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  'Yes',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              result = false;
                                              Navigator.pop(context);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Text('No',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                            ),
                                          )
                                        ],
                                      );
                                    });
                                return result;
                              },
                              key: Key(index.toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                context
                                    .read<ExpenseBloc>()
                                    .add(DeleteExpenseEvent(id: expense.id));
                              },
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddExpenseScreen(
                                                index: index,
                                                forUpdate: true,
                                                expense: expense,
                                              )));
                                },
                                tileColor: ColorUtil.ktileColor,
                                title: Text(expense.title),
                                trailing: Text('Rs. ${expense.amount}'),
                                subtitle: Text(
                                  expense.date,
                                  style: TextStyle(color: ColorUtil.kTextColor),
                                ),
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
          ),
          ListTile(
            tileColor: ColorUtil.ktileColor,
            title: const Text('Total completed expense'),
            trailing: BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpensesLoaded) {
                  calculateTotal(state.expenses
                      .where((element) => !element.futureExpense)
                      .toList());
                  return Text('Rs. $totalExpenses');
                } else {
                  return const Text('...');
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
