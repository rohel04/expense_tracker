import 'package:expense_tracker/features/category/data/datasources/local/category.dart';
import 'package:expense_tracker/features/category/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/expenses/data/datasources/local/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc/expense_bloc.dart';
import 'package:expense_tracker/features/income/data/datasources/local/income.dart';
import 'package:expense_tracker/features/income/presentation/bloc/income_bloc/income_bloc.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:expense_tracker/login_screen.dart';
import 'package:expense_tracker/main_app.dart';
import 'package:expense_tracker/utils/box_constants.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final appDocumentDirectory=await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(IncomeAdapter());
  Hive.registerAdapter(CategoryAdapter());
  await Hive.openBox<Expense>(kExpenseBox);
  await Hive.openBox<Income>(kIncomeBox);
  await Hive.openBox<Category>(kCategoryBox);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseBloc>(create:(context)=>ExpenseBloc()),
        BlocProvider<IncomeBloc>(create:(context)=>IncomeBloc()),
        BlocProvider<CategoryBloc>(create:(context)=>CategoryBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if(snapshot.connectionState==ConnectionState.active)
            {
              var user=snapshot.data;
              if(user==null){
                return const LoginScreen();
              }else{
                return const MainScreen();
                // return const MainScreen();
              }
            }else{
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: ColorUtil.kPrmiaryColor,
            elevation: 0.0
          ),
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: ColorUtil.kTextColor
          )
        ),
      ),
    );
  }
}