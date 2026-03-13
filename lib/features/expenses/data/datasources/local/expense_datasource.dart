import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/expenses/data/datasources/local/expense.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ExpenseDataSource {
  Future<List<Expense>> addExpense(expense);
  Future<List<Expense>> getExpenses();
  Future<List<Expense>> updateExpense(id, expense);
  Future<List<Expense>> deleteExpense(id);
  Future<List<Expense>> filter(month);
}

class ExpenseDataSourceImpl implements ExpenseDataSource {
  CollectionReference<Map<String, dynamic>> _collection() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('expenses')
        .doc(uid)
        .collection('myexpenses');
  }

  Expense _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Expense(
      title: data['title'],
      amount: data['amount'],
      date: data['date'],
      futureExpense: data['future_expense'],
      id: data['id'],
      category: data['category'],
    );
  }

  @override
  Future<List<Expense>> addExpense(expense) async {
    await _collection().doc(expense.id).set({
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date,
      'future_expense': expense.futureExpense,
      'id': expense.id,
      'category': expense.category,
    });
    return getExpenses();
  }

  @override
  Future<List<Expense>> getExpenses() async {
    try {
      final snapshot = await _collection().get();
      return snapshot.docs.map(_fromDoc).toList();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Expense>> updateExpense(id, expense) async {
    try {
      await _collection().doc(id).set({
        'title': expense.title,
        'amount': expense.amount,
        'date': expense.date,
        'future_expense': expense.futureExpense,
        'id': expense.id,
        'category': expense.category,
      });
      return getExpenses();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Expense>> deleteExpense(id) async {
    try {
      await _collection().doc(id).delete();
      return getExpenses();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Expense>> filter(month) async {
    try {
      final expenses = await getExpenses();
      final now = DateTime.now();
      return expenses
          .where((element) =>
              DateTime.parse(element.date).month == month &&
              DateTime.parse(element.date).year == now.year)
          .toList();
    } catch (e) {
      throw Exception();
    }
  }
}
