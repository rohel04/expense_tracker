import 'package:expense_tracker/features/income/data/datasources/local/income.dart';
import 'package:expense_tracker/features/income/presentation/bloc/income_bloc/income_bloc.dart';
import 'package:expense_tracker/features/income/presentation/pages/add_income.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MyFutureIncomes extends StatefulWidget {
  const MyFutureIncomes({super.key});

  @override
  State<MyFutureIncomes> createState() => _MyFutureIncomesState();
}

class _MyFutureIncomesState extends State<MyFutureIncomes> {


  String? totalIncome;
  List<Income> futureIncomes=[];
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
              child: BlocBuilder<IncomeBloc, IncomeState>(
                builder: (context, state) {
                  if (state is IncomeLoaded) {
                    if (state.income.isEmpty) {
                      return const Center(child: Text('No incomes found'));
                    } else {
                      futureIncomes=state.income.where((element) => element.futureIncome).toList();
                      futureIncomes.sort(((a, b) => a.date.compareTo(b.date)));
                      if (futureIncomes.isEmpty) {
                        return const Center(child: Text('No future incomes found'));
                      }else{
                        return ListView.separated(
                          itemCount: futureIncomes.length,
                          itemBuilder: (context, index) {
                            Income income = futureIncomes[index];
                            return Dismissible(                          
                              movementDuration:const Duration(milliseconds: 100),
                              background: Container(
                                color: Colors.green,
                                padding: const EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.mark_email_read_sharp,color: ColorUtil.kTextColor,),
                                    const SizedBox(width: 10),
                                    const Text('Mark as received')
                                  ],
                                ),
                              ),
                              key: Key(index.toString()),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async{
                                DateTime? pickedDate = await showDatePicker(
                                  helpText: 'Select received date',
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(3000));
                                if (pickedDate != null) {
                                  _dateController.text =
                                      DateFormat("yyyy-MM-dd").format(pickedDate);
                                      update(income);
                                      return true;
                                }else{
                                  return false;
                                }
                              },
                              child: ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AddIncomeScreen(index: index,forUpdate: true,income: income,)));
                                },
                                tileColor: ColorUtil.ktileColor,
                                title: Text(income.title),
                                subtitle: Text('Rs. ${income.amount}', style: TextStyle(color: ColorUtil.kTextColor)),
                                trailing: IconButton(onPressed: (){
                                  context.read<IncomeBloc>().add(DeleteIncomeEvent(id: income.id));
                                }, icon: const Icon(Icons.delete,color: Colors.red,)),
                                
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
              title:const Text('Total future Income'),
              trailing: BlocBuilder<IncomeBloc, IncomeState>(
                builder: (context, state) {
                  if(state is IncomeLoaded){
                    calculateTotal(futureIncomes);
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
  update(Income income){
    context.read<IncomeBloc>().add(UpdateIncomeEvent(id: income.id,income: Income(id: income.id, title: income.title, amount: income.amount, date: _dateController.text, futureIncome: !income.futureIncome)));
  }
  calculateTotal(List<Income> incomes){
    var total = 0;
    for (var i in incomes) {
      total = total + int.parse(i.amount);
    }
    totalIncome = total.toString();
  }
}
