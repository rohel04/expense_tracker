import 'package:expense_tracker/features/category/data/datasources/local/category.dart';
import 'package:expense_tracker/features/category/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/category/presentation/pages/add_category.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryHome extends StatefulWidget {
  const CategoryHome({super.key});

  @override
  State<CategoryHome> createState() => _CategoryHomeState();
}

class _CategoryHomeState extends State<CategoryHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.kPrmiaryColor,
      appBar: AppBar(
        title: const Text('Expense Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddCategoryScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if(state is CategoriesLoaded){
              if(state.categories.isEmpty){
                return const Center(
                  child: Text('Expense categories list is empty'),
                );
              }else{
                return ListView.separated(
                  itemCount: state.categories.length,
                  itemBuilder: (context,index){
                    Category category=state.categories[index];
                    return ListTile(
                      tileColor: ColorUtil.ktileColor,
                      title: Text(category.title),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(height: 10);
                  },
                );
              }
            }else{
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
