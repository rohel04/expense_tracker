import 'package:expense_tracker/features/expenses/presentation/pages/expenses.dart';
import 'package:expense_tracker/features/income/presentation/pages/income.dart';
import 'package:expense_tracker/features/sms_expenses/presentation/bloc/sms_transaction_bloc.dart';
import 'package:expense_tracker/features/sms_expenses/presentation/pages/sms_transactions_page.dart';
import 'package:expense_tracker/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  var currentIndex=0;

  List<Widget> pages=[
    const HomeScreen(),
    const MyExpensesScreen(),
    const MyIncomes(),
    const SmsTransactionsPage()
  ];

  static const statementIndex = 3;

  @override
  Widget build(BuildContext context) {
    var height=MediaQuery.of(context).size.height;
    return GestureDetector(
      child: Scaffold(
        backgroundColor: ColorUtil.kPrmiaryColor,   
        body: IndexedStack(
          index: currentIndex,
          children: pages
        ),
     
        bottomNavigationBar: SizedBox(
          height: height*0.09,
          child: BottomNavigationBar(
            backgroundColor: ColorUtil.kBottomNavigationColor,
            selectedItemColor: ColorUtil.kTextColor,
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: ColorUtil.kTextColor.withValues(alpha: 0.6),
            onTap: (index){
              // IndexedStack builds every tab up front, so scan SMS (and ask
              // for the permission) only when the statement is first opened.
              final smsBloc = context.read<SmsTransactionBloc>();
              if (index == statementIndex &&
                  smsBloc.state is SmsTransactionInitial) {
                smsBloc.add(SyncSmsTransactionsEvent());
              }
              setState(() {
                currentIndex=index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home,),
                label: 'Home'
                
              ),
             
              BottomNavigationBarItem(
                icon: Icon(Icons.send_to_mobile_rounded ),
                label: 'Expenses'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.mobile_friendly),
                label: 'Incomes'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: 'Statement'
              ),
            ]
          ),
        ),
      ),
    );
    
  }
}