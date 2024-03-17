import 'package:expense_tracker/common/datasource/sync_datasource.dart';
import 'package:expense_tracker/features/category/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/category/presentation/pages/category_page.dart';
import 'package:expense_tracker/features/expenses/data/datasources/local/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc/expense_bloc.dart';
import 'package:expense_tracker/features/income/data/datasources/local/income.dart';
import 'package:expense_tracker/features/income/presentation/bloc/income_bloc/income_bloc.dart';
import 'package:expense_tracker/fetch.dart';
import 'package:expense_tracker/login_screen.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _balanceController = TextEditingController();
  String? totalExpenses = '0';
  String? totalIncom = '0';
  int totalBalance = 0;
  String fullName = '';
  ValueNotifier totalBalances = ValueNotifier<int>(0);

  @override
  void initState() {
    var month = DateTime.now().month;
    context.read<IncomeBloc>().add(FilterIncomeEvent(month: month));
    context.read<ExpenseBloc>().add(FilterEvent(month: month));
    context.read<CategoryBloc>().add(GetAllCategoryEvent());
    super.initState();
    var name = FirebaseAuth.instance.currentUser!.displayName!;
    fullName = name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  navigate() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ColorUtil.kPrmiaryColor,
      appBar: AppBar(
        title: const Text(
          'Home',
        ),
        actions: [
          IconButton(
              onPressed: () async {
                SyncRemoteDataSource a = SyncRemoteDataSourceImpl();
                await a.logout();
                var shared = await SharedPreferences.getInstance();
                await shared.clear();
                navigate();
              },
              icon: const Icon(
                Icons.logout,
              ))
        ],
      ),
      drawer: Drawer(
        backgroundColor: ColorUtil.kBottomNavigationColor,
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                onTap: () async {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Syncing data')));
                  SyncRemoteDataSource a = SyncRemoteDataSourceImpl();
                  var result = await a.syncExpenses();
                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Data Synced'),
                        backgroundColor: Colors.green));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Data syncing failed'),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                title: const Text('Save data to firebase'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FetchScreen(
                                userId: FirebaseAuth.instance.currentUser!.uid,
                              )),
                      (route) => false);
                },
                title: const Text('Get previous data from firebase'),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CategoryHome()));
                },
                title: const Text('Expense Categories'),
              ),
            ],
          ),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<IncomeBloc, IncomeState>(
            listener: (context, state) {
              if (state is IncomeLoaded) {
                calculateTotalIncome(state.income);
                totalBalance = calculateTotalBalance() ?? 0;
              }
            },
          ),
          BlocListener<ExpenseBloc, ExpenseState>(
            listener: (context, state) {
              if (state is ExpensesLoaded) {
                calculateTotal(state.expenses);
                totalBalance = calculateTotalBalance() ?? 0;
              }
            },
          ),
        ],
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: height * 0.02, horizontal: width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(fullName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900)),
              SizedBox(height: height * 0.01),
              const Text('Welcome Back!',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
              SizedBox(height: height * 0.03),
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: height * 0.02, horizontal: width * 0.03),
                  height: height * 0.22,
                  decoration: BoxDecoration(
                    color: ColorUtil.blue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('Total balance'),
                      SizedBox(
                        height: height * 0.01,
                      ),
                      ValueListenableBuilder(
                        builder: (BuildContext context, value, Widget? child) {
                          return Text(
                            'Rs. ${value ?? 0}',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900),
                          );
                        },
                        valueListenable: totalBalances,
                      ),
                      SizedBox(height: height * 0.02),
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: EdgeInsets.only(right: width * 0.3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 20,
                                      color: Colors.green,
                                    ),
                                    Text(
                                      'Income',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w200),
                                    ),
                                  ],
                                ),
                                BlocBuilder<IncomeBloc, IncomeState>(
                                  builder: (context, state) {
                                    if (state is IncomeLoaded) {
                                      return Text(
                                        '- Rs. ${totalIncom ?? 0}',
                                        style: const TextStyle(fontSize: 16),
                                      );
                                    } else {
                                      return const Text('...');
                                    }
                                  },
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.arrow_drop_up,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    Text(
                                      'Expenses',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w200),
                                    ),
                                  ],
                                ),
                                BlocBuilder<ExpenseBloc, ExpenseState>(
                                  builder: (context, state) {
                                    if (state is ExpensesLoaded) {
                                      return Text(
                                        '- Rs. ${totalExpenses ?? 0}',
                                        style: const TextStyle(fontSize: 16),
                                      );
                                    } else {
                                      return const Text('...');
                                    }
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpensesLoaded) {
                    var currentExpenses = state.expenses
                        .where((element) => !element.futureExpense)
                        .toList();
                    var total = 0;
                    for (var i in currentExpenses) {
                      total = total + int.parse(i.amount);
                    }
                    var totall = double.parse(totalIncom!) - total;
                    return Text(
                      'Your must have $totall for your future expense this month',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              const SizedBox(height: 30),
              const Text('Your expense chart for this month'),
              const SizedBox(height: 30),
              Expanded(
                child: BlocBuilder<ExpenseBloc, ExpenseState>(
                    builder: (context, state) {
                  if (state is ExpensesLoaded) {
                    if (state.expenses.isNotEmpty) {
                      Map<String, double>? dataMap = {};
                      for (var element in state.expenses) {
                        if (element.category != null) {
                          if (dataMap.containsKey(element.category!)) {
                            dataMap[element.category!] =
                                dataMap[element.category!]! +
                                    double.parse(element.amount);
                          } else {
                            dataMap[element.category!] =
                                double.parse(element.amount);
                          }
                        }
                      }
                      return PieChart(
                          dataMap: dataMap,
                          animationDuration: const Duration(milliseconds: 800),
                          chartLegendSpacing: 32,
                          chartRadius: MediaQuery.of(context).size.width / 0.2,
                          initialAngleInDegree: 0,
                          chartType: ChartType.disc,
                          ringStrokeWidth: 32,
                          legendOptions: const LegendOptions(
                            showLegendsInRow: false,
                            legendPosition: LegendPosition.right,
                            showLegends: true,
                          ));
                    } else {
                      return const Text('No expenses found');
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  calculateTotal(List<Expense> expenses) {
    var total = 0;
    for (var i in expenses) {
      total = total + int.parse(i.amount);
    }
    totalExpenses = total.toString();
  }

  calculateTotalIncome(List<Income> income) {
    var total = 0;
    for (var i in income) {
      total = total + int.parse(i.amount);
    }
    totalIncom = total.toString();
  }

  calculateTotalBalance() {
    totalBalances.value =
        int.parse(totalIncom ?? '0') - int.parse(totalExpenses ?? '0');
  }
}
