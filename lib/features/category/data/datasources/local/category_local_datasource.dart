import 'package:expense_tracker/features/category/data/datasources/local/category.dart';
import 'package:expense_tracker/utils/box_constants.dart';
import 'package:hive/hive.dart';

abstract class CategoryLocalDataSource{
  Future<List<Category>> addCategory(id,category);
  Future<List<Category>> updateCategory(category);
  Future<List<Category>> deleteCategory(id);
  Future<List<Category>> getCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource{
  @override
  Future<List<Category>> addCategory(id,category) async{
    final categoryBox=Hive.box<Category>(kCategoryBox);
    await categoryBox.put(id, category);
    var categories=getCategories();
    return categories;
  }

  @override
  Future<List<Category>> deleteCategory(id) async{
    // TODO: implement deleteCategory
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> updateCategory(category) async{
    // TODO: implement updateCategory
    throw UnimplementedError();
  }
  
  @override
  Future<List<Category>> getCategories() async{
    try{
      final categoryBox=Hive.box<Category>(kCategoryBox);
      return categoryBox.values.map((e) => Category(id: e.id, title: e.title)).toList();
    }catch(e){
      throw Exception();
    }
  }

}