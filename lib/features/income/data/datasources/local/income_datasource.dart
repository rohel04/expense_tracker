import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/income/data/datasources/local/income.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class IncomeDataSource {
  Future<List<Income>> addIncome(income);
  Future<List<Income>> getIncomes();
  Future<List<Income>> updateIncome(index, income);
  Future<List<Income>> deleteIncome(index);
  Future<List<Income>> filter(month);
}

class IncomeDataSourceImpl implements IncomeDataSource {
  CollectionReference<Map<String, dynamic>> _collection() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('income')
        .doc(uid)
        .collection('myincomes');
  }

  Income _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Income(
      title: data['title'],
      amount: data['amount'],
      date: data['date'],
      futureIncome: data['future_income'],
      id: data['id'],
    );
  }

  @override
  Future<List<Income>> addIncome(income) async {
    await _collection().doc(income.id).set({
      'title': income.title,
      'amount': income.amount,
      'date': income.date,
      'future_income': income.futureIncome,
      'id': income.id,
    });
    return getIncomes();
  }

  @override
  Future<List<Income>> getIncomes() async {
    try {
      final snapshot = await _collection().get();
      return snapshot.docs.map(_fromDoc).toList();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Income>> updateIncome(id, income) async {
    try {
      await _collection().doc(id).set({
        'title': income.title,
        'amount': income.amount,
        'date': income.date,
        'future_income': income.futureIncome,
        'id': income.id,
      });
      return getIncomes();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Income>> deleteIncome(id) async {
    try {
      await _collection().doc(id).delete();
      return getIncomes();
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<List<Income>> filter(month) async {
    try {
      final incomes = await getIncomes();
      final now = DateTime.now();
      return incomes
          .where((element) =>
              DateTime.parse(element.date).month == month &&
              DateTime.parse(element.date).year == now.year)
          .toList();
    } catch (e) {
      throw Exception();
    }
  }
}
