class Expense {
  String title;
  String amount;
  String date;
  bool futureExpense;
  String id;
  String? category;

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.futureExpense,
    required this.id,
    this.category,
  });
}
