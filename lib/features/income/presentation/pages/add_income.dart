import 'package:expense_tracker/features/income/data/datasources/local/income.dart';
import 'package:expense_tracker/features/income/presentation/bloc/income_bloc/income_bloc.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen(
      {super.key, this.forUpdate = false, this.income, this.index});
  final bool? forUpdate;
  final Income? income;
  final dynamic index;

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool futureIncome = false;

  @override
  void initState() {
    if (widget.forUpdate!) {
      _titleController.text = widget.income!.title;
      _amountController.text = widget.income!.amount;
      _dateController.text = widget.income!.date;
      futureIncome = widget.income!.futureIncome;
    } else {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.forUpdate! ? 'Update Income' : 'Add Income'),
      ),
      drawer: const Drawer(),
      backgroundColor: ColorUtil.kPrmiaryColor,
      body: BlocListener<IncomeBloc, IncomeState>(
        listener: (context, state) {
          if (state is IncomeLoaded) {
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
                      hintText: 'Title of income',
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
                      hintText: 'Amount of income',
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorUtil.kBottomNavigationColor)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorUtil.kBottomNavigationColor))),
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
                      hintText: 'Title of income',
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
                        value: futureIncome,
                        onChanged: (value) {
                          setState(() {
                            futureIncome = value!;
                          });
                        }),
                    const Text('Is this your future income?')
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        String uuid = '';
                        widget.forUpdate!
                            ? context.read<IncomeBloc>().add(UpdateIncomeEvent(
                                id: widget.income!.id,
                                income: Income(
                                    id: widget.income!.id,
                                    title: _titleController.text,
                                    futureIncome: futureIncome,
                                    amount: _amountController.text,
                                    date: _dateController.text,
                                    isSynced: false)))
                            : [
                                uuid = const Uuid().v4(),
                                context.read<IncomeBloc>().add(AddIncomeEvent(
                                    income: Income(
                                        title: _titleController.text,
                                        amount: _amountController.text,
                                        date: _dateController.text,
                                        futureIncome: futureIncome,
                                        id: uuid,
                                        isSynced: false)))
                              ];
                      },
                      child: Text(
                          widget.forUpdate! ? 'Update Income' : 'Add Income')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
