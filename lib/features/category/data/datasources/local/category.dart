import 'package:hive/hive.dart';
part 'category.g.dart';

@HiveType(typeId: 3)
class Category{


@HiveField(0)
  String id;

@HiveField(1)
  String title;


  Category({required this.id, required this.title});


}