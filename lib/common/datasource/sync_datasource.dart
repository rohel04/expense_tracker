import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/features/category/data/datasources/local/category.dart';
import 'package:expense_tracker/features/expenses/data/datasources/local/expense.dart';
import 'package:expense_tracker/features/income/data/datasources/local/income.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/box_constants.dart';

abstract class SyncRemoteDataSource{
  Future<Either<UserCredential,bool>> signInGoogle();
  Future<void> logout();
  Future<bool> syncExpenses();
  Future<void> getFromRemote();
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource{
  @override
  Future<Either<UserCredential,bool>> signInGoogle() async{
    try{
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return Left(await FirebaseAuth.instance.signInWithCredential(credential));
    }catch(e){
      return const Right(false);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

  @override
  Future<void> logout() async{
    try{
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      final expenseBox=Hive.box<Expense>(kExpenseBox);
      final incomeBox=Hive.box<Income>(kIncomeBox);
      final categoryBox=Hive.box<Category>(kCategoryBox);
      incomeBox.clear();
      expenseBox.clear();
      categoryBox.clear();
      
    }on FirebaseAuthException catch(e){
      throw Exception(e);
    }
  }
  
  @override
  Future<bool> syncExpenses() async{
    try{
      final firebaseStore=FirebaseFirestore.instance;
    
      var shared=await SharedPreferences.getInstance();
      var uid=shared.getString('user');
      if(uid!=null){
        final expenseBox=Hive.box<Expense>(kExpenseBox);
        var unSyncedExpenses=expenseBox.values.where((e) => e.isSynced==false).toList();
        // var exp=expenseBox.values.map((e) => Expense(title: e.title, amount: e.amount, date: e.date, futureExpense: e.futureExpense,id: e.id,category: e.category)).toList();
        if(unSyncedExpenses.isNotEmpty){
          for(var element in unSyncedExpenses){
          await firebaseStore.collection('expenses').doc(uid).collection('myexpenses').doc(element.id).set({'title':element.title,'amount':element.amount,'date':element.date,'future_expense':element.futureExpense,'id':element.id,'category':element.category});
          }
        }
        final incomeBox=Hive.box<Income>(kIncomeBox);
        var unSyncedIncomes=incomeBox.values.where((element) => element.isSynced==false).toList();
        // var income=incomeBox.values.map((e) => Income(title: e.title, amount: e.amount, date: e.date, futureIncome: e.futureIncome,id: e.id)).toList();
        if(unSyncedIncomes.isNotEmpty){
          for(var element in unSyncedIncomes){
          await firebaseStore.collection('income').doc(uid).collection('myincomes').doc(element.id).set({'title':element.title,'amount':element.amount,'date':element.date,'future_income':element.futureIncome,'id':element.id});
          }
        }
        final categoryBox=Hive.box<Category>(kCategoryBox);
        var cat=categoryBox.values.map((e) => Category(id: e.id, title: e.title));
        if(cat.isNotEmpty){
          for(var element in cat){
            await firebaseStore.collection('categories').doc(uid).collection('mycategories').doc(element.id).set({'title':element.title,'id':element.id});
          }
        }
        return true;
      }
      return false;      
    }on FirebaseException catch(e){
      return false;
    }
  }
  
  @override
  Future<void> getFromRemote() async{
    try{
      var shared=await SharedPreferences.getInstance();
      var uid=shared.getString('user');
      var resultExpense=await FirebaseFirestore.instance.collection('expenses').doc(uid).collection('myexpenses').get() ;
      var resultIncome=await FirebaseFirestore.instance.collection('income').doc(uid).collection('myincomes').get() ;
      var resultCategories=await FirebaseFirestore.instance.collection('categories').doc(uid).collection('mycategories').get();
    
      final expenseBox=Hive.box<Expense>(kExpenseBox);
      final incomeBox=Hive.box<Income>(kIncomeBox);
      final categoryBox=Hive.box<Category>(kCategoryBox);
      for(var element in resultExpense.docs){
        Expense expense=Expense(title: element['title'], amount: element['amount'], date: element['date'], futureExpense: element['future_expense'], id: element['id'],category: element['category']);
         await expenseBox.put(expense.id, expense);
      }    
      for(var element in resultIncome.docs){
        Income income=Income(title: element['title'], amount: element['amount'], date: element['date'], futureIncome: element['future_income'], id: element['id']);
         await incomeBox.put(income.id, income);
      }    
      for(var element in resultCategories.docs){
        Category cat=Category(title: element['title'],id: element['id']);
         await categoryBox.put(cat.id, cat);
      }    
    }catch(e){
      throw Exception(e);
    }
  }
}