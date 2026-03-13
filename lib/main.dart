import 'package:expense_tracker/features/category/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc/expense_bloc.dart';
import 'package:expense_tracker/features/income/presentation/bloc/income_bloc/income_bloc.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:expense_tracker/login_screen.dart';
import 'package:expense_tracker/main_app.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '781976423389-ftgpk6qtvu68hf814jqo2mvc1tabdg5s.apps.googleusercontent.com',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseBloc>(create: (context) => ExpenseBloc()),
        BlocProvider<IncomeBloc>(create: (context) => IncomeBloc()),
        BlocProvider<CategoryBloc>(create: (context) => CategoryBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              var user = snapshot.data;
              if (user == null) {
                return const LoginScreen();
              } else {
                return const MainScreen();
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        theme: ThemeData(
            useMaterial3: false,
            appBarTheme: AppBarTheme(
                backgroundColor: ColorUtil.kPrmiaryColor, elevation: 0.0),
            textTheme: Theme.of(context)
                .textTheme
                .apply(bodyColor: ColorUtil.kTextColor, fontFamily: "Archivo")),
      ),
    );
  }
}
