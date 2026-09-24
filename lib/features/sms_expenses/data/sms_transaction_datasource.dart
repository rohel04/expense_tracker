import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/sms_expenses/data/bank_sms_parser.dart';
import 'package:expense_tracker/features/sms_expenses/data/sms_transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

abstract class SmsTransactionDataSource {
  /// Reads the SMS inbox, stores newly parsed transactions and returns all
  /// stored ones, newest first.
  Future<List<SmsTransaction>> sync();
  Future<void> setStatus(String id, SmsTransactionStatus status);
}

class SmsTransactionDataSourceImpl implements SmsTransactionDataSource {
  static const _channel = MethodChannel('expense_tracker/sms');
  static const _scanWindow = Duration(days: 90);

  CollectionReference<Map<String, dynamic>> _collection() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('expenses')
        .doc(uid)
        .collection('sms_transactions');
  }

  @override
  Future<List<SmsTransaction>> sync() async {
    final granted = await _channel.invokeMethod<bool>('requestPermission');
    if (granted != true) {
      throw Exception('SMS permission denied');
    }

    final since = DateTime.now().subtract(_scanWindow).millisecondsSinceEpoch;
    final messages = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
            'readInbox', {'sinceMillis': since}) ??
        [];

    final existing = await _collection().get();
    final existingIds = existing.docs.map((d) => d.id).toSet();

    final parsed = <SmsTransaction>[];
    for (final sms in messages) {
      final address = sms['address'] as String? ?? 'unknown';
      final body = sms['body'] as String? ?? '';
      final dateMillis = sms['date'] as int;
      // Stable across SMS backup/restore, unlike the provider's _id.
      final id = '${address}_$dateMillis'.replaceAll(RegExp(r'[^\w-]'), '_');
      if (existingIds.contains(id)) continue;
      final txn = BankSmsParser.parse(
        id: id,
        address: address,
        body: body,
        receivedAt: DateTime.fromMillisecondsSinceEpoch(dateMillis),
      );
      if (txn != null) parsed.add(txn);
    }

    // Firestore batches are capped at 500 writes.
    for (var i = 0; i < parsed.length; i += 500) {
      final batch = FirebaseFirestore.instance.batch();
      for (final txn in parsed.skip(i).take(500)) {
        batch.set(_collection().doc(txn.id), _toMap(txn));
      }
      await batch.commit();
    }

    final all = [...existing.docs.map(_fromDoc), ...parsed];
    all.sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  @override
  Future<void> setStatus(String id, SmsTransactionStatus status) {
    return _collection().doc(id).update({'status': status.name});
  }

  Map<String, dynamic> _toMap(SmsTransaction txn) => {
        'id': txn.id,
        'type': txn.type.name,
        'amount': txn.amount,
        'date': txn.date,
        'merchant': txn.merchant,
        'account': txn.account,
        'bank': txn.bank,
        'status': txn.status.name,
      };

  SmsTransaction _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SmsTransaction(
      id: data['id'],
      type: SmsTransactionType.values.byName(data['type']),
      amount: (data['amount'] as num).toDouble(),
      date: data['date'],
      merchant: data['merchant'],
      account: data['account'],
      // Docs saved before banks were tracked: id is "<sender>_<millis>".
      bank: data['bank'] ??
          BankSmsParser.bankName(doc.id.replaceFirst(RegExp(r'_\d+$'), '')),
      status: SmsTransactionStatus.values.byName(data['status']),
    );
  }
}
