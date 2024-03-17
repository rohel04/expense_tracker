import 'package:expense_tracker/features/category/data/datasources/local/category.dart';
import 'package:expense_tracker/features/category/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/expenses/data/datasources/local/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/bloc/expense_bloc/expense_bloc.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen(
      {super.key, this.forUpdate = false, this.expense, this.index});
  final bool? forUpdate;
  final Expense? expense;
  final dynamic index;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool futureExpense = false;
  String? selectedCat;

  @override
  void initState() {
    if (widget.forUpdate!) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount;
      _dateController.text = widget.expense!.date;
      futureExpense = widget.expense!.futureExpense;
      selectedCat = widget.expense!.category;
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forUpdate! ? 'Update Expense' : 'Add Expense'),
      ),
      drawer: const Drawer(),
      backgroundColor: ColorUtil.kPrmiaryColor,
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpensesLoaded) {
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: SingleChildScrollView(
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
                      hintText: 'Title of expense',
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorUtil.kBottomNavigationColor)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorUtil.kBottomNavigationColor))),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                      prefix: const Text('Rs.'),
                      filled: true,
                      fillColor: ColorUtil.kTextColor,
                      labelText: 'Amount',
                      labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      hintText: 'Amount of expense',
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorUtil.kBottomNavigationColor)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorUtil.kBottomNavigationColor))),
                ),
                const SizedBox(height: 20),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoriesLoaded) {
                      return DropdownButtonFormField(
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: ColorUtil.kTextColor,
                              labelText: 'Category',
                              labelStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ColorUtil.kBottomNavigationColor)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          ColorUtil.kBottomNavigationColor))),
                          value: selectedCat,
                          hint: const Text('Select category'),
                          items: state.categories
                              .map((e) => DropdownMenuItem(
                                  value: e.title, child: Text(e.title)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCat = value;
                            });
                          });
                    } else {
                      return const Text('CategoryLoading');
                    }
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3000));
                    if (pickedDate != null) {
                      _dateController.text =
                          DateFormat("yyyy-MM-dd").format(pickedDate);
                    }
                  },
                  readOnly: true,
                  controller: _dateController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: ColorUtil.kTextColor,
                      labelText: 'Date',
                      suffixIcon: const Icon(Icons.calendar_month),
                      labelStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      hintText: 'Title of expense',
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorUtil.kBottomNavigationColor)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorUtil.kBottomNavigationColor))),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: ColorUtil.kTextColor)),
                        value: futureExpense,
                        onChanged: (value) {
                          setState(() {
                            futureExpense = value!;
                          });
                        }),
                    const Text('Is this your future expense?')
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () async {
                        String uuid = '';
                        widget.forUpdate!
                            ? context.read<ExpenseBloc>().add(
                                UpdateExpenseEvent(
                                    id: widget.expense!.id,
                                    expense: Expense(
                                        id: widget.expense!.id,
                                        title: _titleController.text,
                                        amount: _amountController.text,
                                        futureExpense: futureExpense,
                                        category: selectedCat,
                                        date: _dateController.text,
                                        isSynced: false)))
                            : [
                                uuid = const Uuid().v4(),
                                context.read<ExpenseBloc>().add(AddExpenseEvent(
                                    expense: Expense(
                                        title: _titleController.text,
                                        amount: _amountController.text,
                                        futureExpense: futureExpense,
                                        date: _dateController.text,
                                        category: selectedCat,
                                        id: uuid,
                                        isSynced: false)))
                              ];
                      },
                      child: Text(widget.forUpdate!
                          ? 'Update Expense'
                          : 'Add Expense')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
