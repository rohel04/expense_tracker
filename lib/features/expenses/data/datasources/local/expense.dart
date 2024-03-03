import 'package:hive/hive.dart';
part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense{


@HiveField(0)
  String title;

@HiveField(1)
  String amount;

@HiveField(2)
  String date;

@HiveField(3)
  bool futureExpense;

 @HiveField(4) 
  String id;

@HiveField(5)
  String? category;

@HiveField(6)
  bool isSynced;

  Expense({required this.title,required this.amount,required this.date,required this.futureExpense,required this.id,this.category,this.isSynced=true});

}