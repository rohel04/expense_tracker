import 'package:expense_tracker/features/income/data/datasources/local/income.dart';
import 'package:expense_tracker/features/income/presentation/bloc/income_bloc/income_bloc.dart';
import 'package:expense_tracker/features/income/presentation/pages/add_income.dart';
import 'package:expense_tracker/features/income/presentation/pages/future_income.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyIncomes extends StatefulWidget {
  const MyIncomes({super.key});

  @override
  State<MyIncomes> createState() => _MyIncomesState();
}

class _MyIncomesState extends State<MyIncomes> {


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
  String? totalIncome;
  List<Income> currentIncomes=[];

  @override
  void initState() {
    monthValue=DateTime.now().month;
    context.read<IncomeBloc>().add(FilterIncomeEvent(month: monthValue));
    filterDate=month[monthValue-1];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Incomes'),
          bottom:const TabBar(tabs: [
            Tab(child: Text('Received')),
            Tab(child: Text('Future')),
          ]),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddIncomeScreen()));
                },
                icon:const Icon(Icons.add))
          ],
        ),
        backgroundColor: ColorUtil.kPrmiaryColor,
        body: TabBarView(
          children: [
            currentIncome(),
            const MyFutureIncomes()
          ],
        )
      ),
    );
  }
  calculateTotal(List<Income> incomes){
    var total = 0;
    for (var i in incomes) {
      total = total + int.parse(i.amount);
    }
    totalIncome = total.toString();
  }

  Widget currentIncome(){
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            Align(
            alignment: Alignment.topRight,
            child: BlocBuilder<IncomeBloc, IncomeState>(
              builder: (context, state) {
                return DropdownButton(
                    value: filterDate,
                    items: month
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        filterDate = value;
                        monthValue = month.indexOf(filterDate!) + 1;
                      });
                      context
                          .read<IncomeBloc>()
                          .add(FilterIncomeEvent(month: monthValue));
                    });
              },
            ),
          ),
            Expanded(
              child: BlocBuilder<IncomeBloc, IncomeState>(
                builder: (context, state) {
                  if (state is IncomeLoaded) {
                    if (state.income.isEmpty) {
                      return const Center(child: Text('No incomes found'));
                    } else {
                      currentIncomes=state.income.where((element) => !element.futureIncome).toList();
                      currentIncomes.sort(((a, b) => a.date.compareTo(b.date)));
                      if (currentIncomes.isEmpty) {
                        return const Center(child: Text('No received incomes found'));
                      }else{
                        return ListView.separated(
                          itemCount: currentIncomes.length,
                          itemBuilder: (context, index) {
                            Income income = currentIncomes[index];
                            return Dismissible(
                              movementDuration:const Duration(milliseconds: 100),
                              background: Container(
                                color: Colors.red,
                                child: const Icon(Icons.delete),
                              ),
                              key: Key(index.toString()),
                              direction: DismissDirection.endToStart,
                             confirmDismiss: (direction) async{
                               bool result=false;
                                await showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      title:const Text('You sure want to delete?',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                                      actions: [
                                        InkWell(
                                          onTap: (){
                                            result=true;
                                            Navigator.pop(context);
                                          },
                                          child:const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text('Yes',style: TextStyle(color: Colors.black),)),
                                        ),
                                        InkWell(
                                          onTap: (){
                                            result=false;
                                            Navigator.pop(context);
                                          },
                                          child:const Padding(
                                            padding:EdgeInsets.all(10),
                                            child: Text('No',style: TextStyle(color: Colors.black)),
                                          ),
                                        )
                                      ],
                                    );
                                  }
                                );
                                return result;
                             },
                             onDismissed: (direction) {
                               context.read<IncomeBloc>().add(DeleteIncomeEvent(id: income.id));
                             },
                              child: ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddIncomeScreen(index: index,forUpdate: true,income: income,)));
                                },
                                tileColor: ColorUtil.ktileColor,
                                title: Text(income.title),
                                trailing: Text('Rs. ${income.amount}'),
                                subtitle: Text(
                                  income.date,
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
            ListTile(
              tileColor: ColorUtil.ktileColor,
              title:const Text('Total received Income'),
              trailing: BlocBuilder<IncomeBloc, IncomeState>(
                builder: (context, state) {
                  if(state is IncomeLoaded){
                    calculateTotal(currentIncomes);
                    return Text('Rs. $totalIncome');
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
}
