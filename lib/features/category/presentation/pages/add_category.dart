import 'package:expense_tracker/features/category/data/datasources/local/category.dart';
import 'package:expense_tracker/features/category/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.kPrmiaryColor,
      appBar: AppBar(
        title: const Text('Add category'),
      ),
      body: BlocListener<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if(state is CategoriesLoaded){
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: ColorUtil.kTextColor,
                    labelText: 'Title',
                    labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    hintText: 'Title of category',
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorUtil.kBottomNavigationColor)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorUtil.kBottomNavigationColor))),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      String uuid = '';
                      uuid = const Uuid().v4();
                      Category category =
                          Category(id: uuid, title: _titleController.text);
                      context
                          .read<CategoryBloc>()
                          .add(AddCategoryEvent(id: uuid, category: category));
                    },
                    child: const Text('Add Category')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
