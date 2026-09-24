import 'package:expense_tracker/features/sms_expenses/data/bank_sms_parser.dart';
import 'package:expense_tracker/features/sms_expenses/data/sms_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final received = DateTime(2026, 9, 25);

  SmsTransaction? parse(String body) => BankSmsParser.parse(
      id: 'id', address: 'CTZNS_Alert', body: body, receivedAt: received);

  test('names bank from sender id', () {
    expect(BankSmsParser.bankName('CTZNS_Alert'), 'Citizens Bank');
    expect(BankSmsParser.bankName('NMB_ALERT'), 'NMB Bank');
    expect(BankSmsParser.bankName('SCLALERT'), 'SCL');
    expect(BankSmsParser.bankName('Khalti'), 'Khalti');
  });

  test('parses sample debit SMS', () {
    final txn = parse('Dear Customer, Your A/C XX1234 has been debited\n'
        'with NPR 1,250.00 on 24-Sep-2026 at XYZ Store.')!;
    expect(txn.type, SmsTransactionType.debit);
    expect(txn.amount, 1250.0);
    expect(txn.date, '2026-09-24');
    expect(txn.merchant, 'XYZ Store');
    expect(txn.account, 'XX1234');
  });

  test('parses credit SMS with uppercase month', () {
    final txn = parse('Dear Customer, Your A/C XX1234 has been credited '
        'with NPR 50,000 on 01-SEP-2026.')!;
    expect(txn.type, SmsTransactionType.credit);
    expect(txn.amount, 50000.0);
    expect(txn.date, '2026-09-01');
    expect(txn.merchant, 'Bank credit');
  });

  test('ignores available balance amount', () {
    final txn = parse('Avl Bal NPR 9,999.00. Your A/C XX1234 has been '
        'debited with NPR 300.50 at Cafe.')!;
    expect(txn.amount, 300.5);
    expect(txn.date, '2026-09-25');
  });

  test('skips non-transaction and failed messages', () {
    expect(parse('Your OTP is 123456. Do not share.'), isNull);
    expect(parse('Your A/C XX1234 will be debited with NPR 500 tomorrow.'),
        isNull);
    expect(parse('Transaction of NPR 500 failed. A/C not debited.'), isNull);
  });

  test('parses Citizens Bank debit with masked account and ISO date', () {
    final txn = parse('Dear ROHEL, ###9041 is debited by NPR 2,039.00 on '
        '2026-09-19, Remarks: POS/459521x9831/60106574/158367/DARAZ KAYMU '
        'PVT LT. Support Center: 01-5970068')!;
    expect(txn.type, SmsTransactionType.debit);
    expect(txn.amount, 2039.0);
    expect(txn.date, '2026-09-19');
    expect(txn.account, '###9041');
    expect(txn.merchant, 'Card payment - DARAZ KAYMU PVT LT');
  });

  test('names ATM and mobile banking remarks', () {
    expect(
        parse('Dear ROHEL, ###9041 is debited by NPR 2,000.00 on 2026-09-06, '
                'Remarks: ATM/459521x9831/CTZN0105/938064/CTZN NAR. '
                'Support Center: 01-5970068')!
            .merchant,
        'ATM withdrawal');
    expect(
        parse('Dear ROHEL, ###9041 is debited by NPR 1,640.00 on 2026-09-18, '
                'Remarks: MB/9860939360/ESEWA,124077721Utility Pa/9860939360. '
                'Support Center: 01-5970068')!
            .merchant,
        'Mobile banking - eSewa');
  });

  test('drops balance text from merchant', () {
    final txn = parse('Dear ROHEL, ###9041 is debited by NPR 648.00 on '
        '01/07/2026, Remarks: POS/459521x9831/6010 Av Bal: 224480.27. '
        'Support Center:01-5970068')!;
    expect(txn.amount, 648.0);
    expect(txn.date, '2026-07-01');
    expect(txn.merchant, 'Card payment - 6010');
  });

  test('parses NMB deposit with day-first slash date', () {
    final txn = parse('A/C 0#11 deposited NPR 62,532.48 on 07/06/2026 '
        '(CPS-SALARY OF MAY 20).For Support:01-5970150')!;
    expect(txn.type, SmsTransactionType.credit);
    expect(txn.amount, 62532.48);
    expect(txn.date, '2026-06-07');
    expect(txn.account, '0#11');
    expect(txn.merchant, 'CPS-SALARY OF MAY 20');
  });

  test('skips messages without account number or amount', () {
    expect(
        parse('Service Number 9767476958 has been credited for 210.76Rupees, '
            'your new balance is 330.69Rupees'),
        isNull);
    expect(parse('NPR 1,250.00 debited on 24-Sep-2026 at XYZ Store.'), isNull);
    expect(parse('Your A/C XX1234 has been debited. Call 1660 for details.'),
        isNull);
  });
}
