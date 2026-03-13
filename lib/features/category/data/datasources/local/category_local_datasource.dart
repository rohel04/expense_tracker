import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/category/data/datasources/local/category.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class CategoryLocalDataSource {
  Future<List<Category>> addCategory(id, category);
  Future<List<Category>> updateCategory(category);
  Future<List<Category>> deleteCategory(id);
  Future<List<Category>> getCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  CollectionReference<Map<String, dynamic>> _collection() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('categories')
        .doc(uid)
        .collection('mycategories');
  }

  @override
  Future<List<Category>> addCategory(id, category) async {
    await _collection().doc(id).set({
      'id': category.id,
      'title': category.title,
    });
    return getCategories();
  }

  @override
  Future<List<Category>> deleteCategory(id) async {
    await _collection().doc(id).delete();
    return getCategories();
  }

  @override
  Future<List<Category>> updateCategory(category) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await _collection().get();
      return snapshot.docs
          .map((doc) => Category(id: doc['id'], title: doc['title']))
          .toList();
    } catch (e) {
      throw Exception();
    }
  }
}
