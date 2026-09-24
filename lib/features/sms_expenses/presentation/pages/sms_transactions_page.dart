import 'package:expense_tracker/features/sms_expenses/data/sms_transaction.dart';
import 'package:expense_tracker/features/sms_expenses/presentation/bloc/sms_transaction_bloc.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SmsTransactionsPage extends StatefulWidget {
  const SmsTransactionsPage({super.key});

  @override
  State<SmsTransactionsPage> createState() => _SmsTransactionsPageState();
}

class _SmsTransactionsPageState extends State<SmsTransactionsPage> {
  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _labelFormat = DateFormat('dd MMM yyyy');

  // Defaults to the current month.
  DateTimeRange _range = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  );

  bool _inRange(SmsTransaction txn) =>
      txn.date.compareTo(_dateFormat.format(_range.start)) >= 0 &&
      txn.date.compareTo(_dateFormat.format(_range.end)) <= 0;

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2000),
      lastDate: DateTime(3000),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: ColorUtil.blue,
            onPrimary: ColorUtil.kTextColor,
            surface: ColorUtil.kPrmiaryColor,
            onSurface: ColorUtil.kTextColor,
          ),
          scaffoldBackgroundColor: ColorUtil.kPrmiaryColor,
          dialogTheme:
              DialogThemeData(backgroundColor: ColorUtil.kPrmiaryColor),
          appBarTheme: AppBarTheme(
            backgroundColor: ColorUtil.kPrmiaryColor,
            foregroundColor: ColorUtil.kTextColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.kPrmiaryColor,
      appBar: AppBar(
        title: const Text('Statement'),
        actions: [
          IconButton(
              onPressed: () => context
                  .read<SmsTransactionBloc>()
                  .add(SyncSmsTransactionsEvent()),
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: BlocBuilder<SmsTransactionBloc, SmsTransactionState>(
        builder: (context, state) {
          if (state is SmsTransactionsError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(state.message, textAlign: TextAlign.center),
            ));
          }
          if (state is! SmsTransactionsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          // Ignored messages (e.g. own-account transfers) are left out of
          // the totals as well as the list.
          final inRange = state.transactions
              .where((t) =>
                  t.status != SmsTransactionStatus.ignored && _inRange(t))
              .toList();
          final byBank = <String, List<SmsTransaction>>{};
          for (final txn in inRange) {
            byBank.putIfAbsent(txn.bank, () => []).add(txn);
          }
          final banks = byBank.keys.toList()..sort();
          return Column(
            children: [
              _summary(inRange),
              Expanded(
                child: banks.isEmpty
                    ? const Center(child: Text('No bank transactions'))
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        children: [
                          for (final bank in banks) ...[
                            _bankHeader(bank, byBank[bank]!),
                            ...byBank[bank]!.map(_tile),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _total(List<SmsTransaction> transactions, SmsTransactionType type) =>
      transactions
          .where((t) => t.type == type)
          .fold(0, (sum, t) => sum + t.amount);

  Widget _bankHeader(String bank, List<SmsTransaction> transactions) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(bank,
                style: TextStyle(
                    color: ColorUtil.kTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          Text(
              'In ${_total(transactions, SmsTransactionType.credit).toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green)),
          const SizedBox(width: 12),
          Text(
              'Out ${_total(transactions, SmsTransactionType.debit).toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _summary(List<SmsTransaction> transactions) {
    return Card(
      color: ColorUtil.blue,
      margin: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _pickRange,
              child: Row(
                children: [
                  const Icon(Icons.date_range, size: 18),
                  const SizedBox(width: 6),
                  Text(
                      '${_labelFormat.format(_range.start)} - '
                      '${_labelFormat.format(_range.end)}',
                      style: TextStyle(color: ColorUtil.kTextColor)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _totalColumn(
                    'Incoming',
                    _total(transactions, SmsTransactionType.credit),
                    Icons.arrow_drop_down,
                    Colors.green),
                _totalColumn(
                    'Outgoing',
                    _total(transactions, SmsTransactionType.debit),
                    Icons.arrow_drop_up,
                    Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalColumn(String label, double amount, IconData icon, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 20),
            Text(label, style: TextStyle(color: ColorUtil.kTextColor)),
          ]),
          Text('Rs. ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  color: ColorUtil.kTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _tile(SmsTransaction txn) {
    final isDebit = txn.type == SmsTransactionType.debit;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: ColorUtil.ktileColor,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        horizontalTitleGap: 4,
        leading: Icon(isDebit ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: isDebit ? Colors.red : Colors.green, size: 32),
        title:
            Text(txn.merchant, style: TextStyle(color: ColorUtil.kTextColor)),
        subtitle: Text(
            '${txn.date}${txn.account != null ? '  ·  A/C ${txn.account}' : ''}',
            style:
                TextStyle(color: ColorUtil.kTextColor.withValues(alpha: 0.6))),
        trailing: Text('Rs. ${txn.amount.toStringAsFixed(2)}',
            style: TextStyle(color: ColorUtil.kTextColor)),
      ),
    );
  }
}
