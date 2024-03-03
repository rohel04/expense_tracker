import 'package:hive/hive.dart';
part 'income.g.dart';

@HiveType(typeId: 2)
class Income{

@HiveField(0)
  String title;

@HiveField(1)
  String amount;

@HiveField(2)
  String date;

@HiveField(3)
  bool futureIncome;

@HiveField(4)
  String id;

@HiveField(5)
  bool isSynced;

  Income({required this.id,required this.title,required this.amount,required this.date,required this.futureIncome,this.isSynced=true});

}