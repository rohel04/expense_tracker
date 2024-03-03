import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc/expense_bloc.dart';
import 'package:expense_tracker/features/income/presentation/bloc/income_bloc/income_bloc.dart';
import 'package:expense_tracker/main_app.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FetchScreen extends StatefulWidget {
  final dynamic userId;
  const FetchScreen({super.key, this.userId});

  @override
  State<FetchScreen> createState() => _FetchScreenState();
}


class _FetchScreenState extends State<FetchScreen> {

  @override
  void initState() {
    context.read<ExpenseBloc>().add(BulkAddExpensesEvent());
    super.initState();
  }

  var month=DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.kPrmiaryColor,
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if(state is FetchDataComplete){
            context.read<ExpenseBloc>().add(FilterEvent(month: month));
            context.read<IncomeBloc>().add(FilterIncomeEvent(month: month));
            // Navigator.pushAndR(context, MaterialPageRoute(builder: (context)=>const MainScreen()), (route) => false);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const MainScreen()));
          }
        },
        child:SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Colors.white,),
                  SizedBox(height: 10),
                  Text('Fetching your data')
                ],
              ),
            )
            
            ),
      ),
    );
  }
}
